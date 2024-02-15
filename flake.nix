{
  description = "Zhaith's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    grub2-themes = {
      url = "github:/vinceliuice/grub2-themes";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zhaith-neovim = {
      url = "gitlab:Zhaith-Izaliel/neovim-config/develop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zhaith-helix = {
      url = "gitlab:Zhaith-Izaliel/helix-config/develop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-contrib = {
      url = "github:hyprwm/contrib";
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
  };

  outputs = {
    nixpkgs,
    nixpkgs-stable,
    grub2-themes,
    nix-alien,
    zhaith-neovim,
    hyprland,
    hyprland-contrib,
    sddm-sugar-candy-nix,
    virgutils,
    rofi-applets,
    zhaith-helix,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    customHelpers = import ./utils {inherit inputs;};
    modules = import ./modules {};
    customOverlay = import ./overlay {inherit inputs;};
  in
    with import nixpkgs {inherit system;}; {
      nixosConfigurations = {
        Whispering-Willow = customHelpers.mkSystem {
          inherit system;
          hostname = "Whispering-Willow";
          users = ["zhaith"];
          extraModules = [
            grub2-themes.nixosModules.default
            sddm-sugar-candy-nix.nixosModules.default
            modules.system
          ];
          overlays = [
            nix-alien.overlays.default
            hyprland.overlays.default
            hyprland-contrib.overlays.default
            sddm-sugar-candy-nix.overlays.default
            virgutils.overlays.${system}.default
            customOverlay
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
          ];
          extraModules = [
            grub2-themes.nixosModules.default
            modules.server
          ];
        };
      };
      homeConfigurations = {
        "zhaith@Whispering-Willow" = customHelpers.mkHome {
          inherit system;
          username = "zhaith";
          hostname = "Whispering-Willow";
          stateVersion = "22.05";
          extraModules = [
            zhaith-neovim.homeManagerModules.default
            zhaith-helix.homeManagerModules.default
            modules.home-manager
            rofi-applets.homeManagerModules.default
          ];
          overlays = [
            hyprland.overlays.default
            hyprland-contrib.overlays.default
            virgutils.overlays.${system}.default
            rofi-applets.overlays.default
            customOverlay
          ];
        };

        "lilith@Ethereal-Edelweiss" = customHelpers.mkHome {
          inherit system;
          username = "lilith";
          hostname = "Ethereal-Edelweiss";
          stateVersion = "21.05";
          nixpkgs = nixpkgs-stable;
        };
      };

      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          alejandra
          home-manager
        ];
      };
    };
}
