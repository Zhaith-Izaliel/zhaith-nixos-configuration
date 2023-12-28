{ inputs }:

let
  lib = inputs.nixpkgs.lib;
in
{
  mkSystem = { hostname, system, users ? [ ], extraModules ? [ ], overlays ? [
  ], nixpkgs ? inputs.nixpkgs }:
    let
      pkgs = import nixpkgs {
        inherit overlays system;
      };
      types = import ../types { inherit lib pkgs; };
    in
    lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit hostname system inputs;
        extra-types = types;
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
    overlays ? [ ], nixpkgs ? inputs.nixpkgs, home-manager ?
    inputs.home-manager }:
    let
      types = import ../types { inherit lib pkgs; };
      pkgs = import nixpkgs {
        inherit overlays system;
      };
    in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      extraSpecialArgs = {
        inherit system hostname inputs;
        extra-types = types;
        stable-pkgs = import inputs.nixpkgs-stable {
          inherit overlays system;
        };
        unstable-pkgs = import inputs.nixpkgs {
          inherit overlays system;
        };
        os-config = inputs.self.nixosConfigurations.${hostname}.config;
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

