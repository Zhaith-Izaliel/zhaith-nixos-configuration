{ attrs }:
{
  mkSystem = { hostname, system, users ? [ ]}:
    let
      pkgs = attrs.nixpkgs.legacyPackages.${system};
    in
    attrs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit  hostname system attrs;
        unstable-pkgs = attrs.nixpkgs-unstable.legacyPackages.${system};
      };
      modules = [
        ../hosts/${hostname}
        {
          networking.hostName = hostname;

          # Allow unfree packages
          nixpkgs = {
            config.allowUnfree = true;
          };

          nix = {
            package = pkgs.nixFlakes;

            extraOptions = ''
            experimental-features = nix-command flakes
            '';

            # Add each input as a registry
            registry = attrs.nixpkgs.lib.mapAttrs'
            (n: v: attrs.nixpkgs.lib.nameValuePair n { flake = v; })
            attrs;
          };
        }
      ] ++ attrs.nixpkgs.lib.forEach users (u: ../users/${u}/system);
    };

    mkHome = { username, system, hostname, stateVersion }:
    attrs.home-manager.lib.homeManagerConfiguration {
      extraSpecialArgs = {
        inherit  system hostname;inputs = attrs;
        unstable-pkgs = builtins.getAttr system attrs.nixpkgs-unstable.outputs.legacyPackages;
      };
      pkgs = builtins.getAttr system attrs.nixpkgs.outputs.legacyPackages;
      modules = [
        ../users/${username}/home
        {
          nixpkgs = {
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
      ];
    };
  }
