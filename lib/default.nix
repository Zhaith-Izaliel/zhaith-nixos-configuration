{ inputs }:
{
  mkSystem = { hostname, system, users ? [ ], extraModules ? [ ], overlays ? [ ] }:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit  hostname system inputs;
        unstable-pkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
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
            package = pkgs.nixFlakes;

            extraOptions = ''
            experimental-features = nix-command flakes
            '';

            # Add each input as a registry
            registry = inputs.nixpkgs.lib.mapAttrs'
            (n: v: inputs.nixpkgs.lib.nameValuePair n { flake = v; })
            inputs;
          };
        }
      ] ++ inputs.nixpkgs.lib.forEach users (u: ../users/${u}/system)
      ++ extraModules;
    };

    mkHome = { username, system, hostname, stateVersion, extraModules ? [ ], overlays ? [ ] }:
    inputs.home-manager.lib.homeManagerConfiguration {
      extraSpecialArgs = {
        inherit system hostname inputs;
        unstable-pkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
      };
      pkgs = builtins.getAttr system inputs.nixpkgs.outputs.legacyPackages;
      modules = [
        ../users/${username}/home
        {
          nixpkgs = {
            inherit overlays;
            config.allowUnfree = true;
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

