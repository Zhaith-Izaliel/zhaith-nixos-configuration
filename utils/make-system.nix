{inputs}: {
  mkSystem = {
    hostname,
    system,
    users ? [],
    extraModules ? [],
    overlays ? [
    ],
    nixpkgs ? inputs.nixpkgs,
  }: let
    lib = nixpkgs.lib;
    pkgs = import nixpkgs {
      inherit overlays system;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };
    types = import ../types {inherit lib pkgs inputs;};
    stable-pkgs = import inputs.nixpkgs-stable {
      inherit overlays system;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };
    unstable-pkgs = import inputs.nixpkgs {
      inherit overlays system;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };
  in
    lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit hostname system inputs stable-pkgs unstable-pkgs;
        extra-types = types;
      };
      modules =
        [
          ../hosts/${hostname}
          {
            networking.hostName = hostname;

            # Allow unfree packages
            nixpkgs = {
              inherit overlays;
              config = {
                allowUnfree = true;
                allowUnfreePredicate = _: true;
              };
            };

            nix = {
              enable = true;

              extraOptions = ''
                experimental-features = nix-command flakes
              '';
            };
          }
        ]
        ++ nixpkgs.lib.forEach users (u: ../users/${u}/system)
        ++ extraModules;
    };

  mkHome = {
    username,
    system,
    hostname,
    stateVersion,
    extraModules ? [],
    overlays ? [],
    nixpkgs ? inputs.nixpkgs,
    home-manager ? inputs.home-manager,
  }: let
    lib = nixpkgs.lib;
    types = import ../types {inherit lib pkgs inputs;};
    pkgs = import nixpkgs {
      inherit overlays system;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };
    stable-pkgs = import inputs.nixpkgs-stable {
      inherit overlays system;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };
    unstable-pkgs = import inputs.nixpkgs {
      inherit overlays system;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };
  in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      extraSpecialArgs = {
        inherit system hostname inputs stable-pkgs unstable-pkgs;
        extra-types = types;
        os-config = inputs.self.nixosConfigurations.${hostname}.config;
      };

      modules =
        [
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
        ]
        ++ extraModules;
    };
}
