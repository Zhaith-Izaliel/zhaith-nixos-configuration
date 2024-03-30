{
  description = "Zhaith's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    grub2-themes = {
      url = "github:/vinceliuice/grub2-themes";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # zhaith-neovim = {
    #   url = "gitlab:Zhaith-Izaliel/neovim-config/develop";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    zhaith-helix = {
      url = "gitlab:Zhaith-Izaliel/helix-config/develop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hypridle = {
      url = "github:/hyprwm/hypridle";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sddm-sugar-candy-nix = {
      url = "gitlab:Zhaith-Izaliel/sddm-sugar-candy-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    virgutils = {
      url = "gitlab:Zhaith-Izaliel/virgutils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rofi-applets = {
      url = "gitlab:Zhaith-Izaliel/rofi-applets";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    virgilribeyre-com = {
      url = "gitlab:Zhaith-Izaliel/virgilribeyre.com-next";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # Theme packages
    # NOTE: include them as "{theme-name}-{app-name}"

    # Catppuccin
    catppuccin-bat = {
      url = "github:catppuccin/bat";
      flake = false;
    };

    catppuccin-fcitx5 = {
      url = "github:catppuccin/fcitx5";
      flake = false;
    };

    catppuccin-gitui = {
      url = "github:catppuccin/gitui";
      flake = false;
    };

    catppuccin-alacritty = {
      url = "github:catppuccin/alacritty";
      flake = false;
    };

    catppuccin-hyprland = {
      url = "github:catppuccin/hyprland";
      flake = false;
    };

    catppuccin-starship = {
      url = "github:catppuccin/starship";
      flake = false;
    };

    catppuccin-yazi = {
      url = "github:catppuccin/yazi";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    nixpkgs-stable,
    grub2-themes,
    nix-alien,
    hypridle,
    sddm-sugar-candy-nix,
    virgutils,
    rofi-applets,
    zhaith-helix,
    home-manager-stable,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    customHelpers = import ./utils {inherit inputs;};
    modules = import ./modules {
      extraSystemModules = [
        grub2-themes.nixosModules.default
        sddm-sugar-candy-nix.nixosModules.default
      ];

      extraHomeManagerModules = [
        zhaith-helix.homeManagerModules.default
        rofi-applets.homeManagerModules.default
        hypridle.homeManagerModules.default
      ];

      extraServerModules = [];
    };
    customOverlay = import ./overlay {inherit inputs;};
    overlays = [
      nix-alien.overlays.default
      sddm-sugar-candy-nix.overlays.default
      virgutils.overlays.${system}.default
      customOverlay
    ];
  in
    with import nixpkgs {inherit system;}; {
      nixosConfigurations = {
        Whispering-Willow = customHelpers.mkSystem {
          inherit system overlays;
          hostname = "Whispering-Willow";
          users = ["zhaith"];
          extraModules = [
            modules.system
          ];
        };
        Ethereal-Edelweiss = customHelpers.mkSystem {
          inherit system;
          hostname = "Ethereal-Edelweiss";
          users = ["lilith"];
          nixpkgs = nixpkgs-stable;
          overlays = [
            (final: prev: {
              power-management = virgutils.packages.${system}.power-management;
            })
            customOverlay
          ];
          extraModules = [
            modules.server
            modules.system
          ];
        };
      };
      homeConfigurations = let
        extraModules = [
          modules.home-manager
        ];
      in {
        "zhaith@Whispering-Willow" = customHelpers.mkHome {
          inherit system overlays extraModules;
          username = "zhaith";
          hostname = "Whispering-Willow";
          stateVersion = "23.11";
        };

        "lilith@Ethereal-Edelweiss" = customHelpers.mkHome {
          inherit system overlays extraModules;
          nixpkgs = nixpkgs-stable;
          home-manager = home-manager-stable;
          username = "lilith";
          hostname = "Ethereal-Edelweiss";
          stateVersion = "22.05";
        };
      };

      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          git
          alejandra
          home-manager
          gnumake
          nil
        ];
      };
    };
}
