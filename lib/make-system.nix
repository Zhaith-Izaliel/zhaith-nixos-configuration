{ inputs }:

let
  types = import ./types.nix { inherit lib; };
  lib = inputs.nixpkgs.lib;
in
{
  mkSystem = { hostname, system, users ? [ ], extraModules ? [ ], overlays ? [
  ], theme ? "", nixpkgs ? inputs.nixpkgs }:
    let
      pkgs = import nixpkgs {
        inherit overlays system;
      };
      theme-set = (import ../themes { inherit lib pkgs; }).${theme};
    in
    lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit hostname system inputs;
        extraTypes = types;
        theme = theme-set;
        stable-pkgs = import inputs.nixpkgs-stable {
          inherit overlays system;
        };
        unstable-pkgs = import inputs.nixpkgs {
          inherit overlays system;
        };
      };
      modules = [
        ../hosts/${hostname}
        {
          networking.hostName = hostname;

          # Allow unfree packages
          nixpkgs = {
            inherit overlays;
            config.allowUnfree = true;
          };

          nix = {
            enable = true;

            extraOptions = ''
            experimental-features = nix-command flakes
            '';

            # Add each input as a registry
            registry = inputs.nixpkgs.lib.mapAttrs'
            (n: v: inputs.nixpkgs.lib.nameValuePair n { flake = v; })
            inputs;
          };
        }
      ] ++ nixpkgs.lib.forEach users (u: ../users/${u}/system)
      ++ extraModules;
    };

    mkHome = { username, system, hostname, stateVersion, extraModules ? [ ],
    overlays ? [ ], theme ? "", nixpkgs ? inputs.nixpkgs, home-manager ?
    inputs.home-manager }:
    let
      pkgs = import nixpkgs {
        inherit overlays system;
      };
      theme-set = (import ../themes { inherit pkgs lib; }).${theme};
    in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      extraSpecialArgs = {
        inherit system hostname inputs;
        theme = theme-set;
        extraTypes = types;
        stable-pkgs = import inputs.nixpkgs-stable {
          inherit overlays system;
        };
        unstable-pkgs = import inputs.nixpkgs {
          inherit overlays system;
        };
        osConfig = inputs.self.nixosConfigurations.${hostname}.config;
      };

      modules = [
        ../users/${username}/home
        {
          nixpkgs = {
            inherit overlays;
            config = {
              allowUnfree = true;
              allowUnfreePredicate = _: true;
            };
          };
          programs = {
            home-manager.enable = true;
            git.enable = true;
          };

          home = {
            inherit username stateVersion;
            homeDirectory = "/home/${username}";
          };
        }
      ] ++ extraModules;
    };
  }

