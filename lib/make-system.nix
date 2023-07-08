{ inputs }:

{
  mkSystem = { hostname, system, users ? [ ], extraModules ? [ ], overlays ? [ ] }:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      theme = import ../theme/default.nix { inherit pkgs lib; };
      lib = inputs.nixpkgs.lib;
    in
    lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit hostname system inputs theme;
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
    let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      lib = inputs.nixpkgs.lib;
      theme = import ../theme/default.nix { inherit pkgs lib; };
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      extraSpecialArgs = {
        inherit system hostname inputs theme;
        unstable-pkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
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

