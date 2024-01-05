{
  description = "Zhaith's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

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
      url = "gitlab:Zhaith-Izaliel/rofi-applets/develop";
      inputs.nixpkgs.follows = "nixpkgs";
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
    catppuccin-hyprland = {
      url = "github:catppuccin/hyprland";
      flake = false;
    };
    catppuccin-starship = {
      url = "github:catppuccin/starship";
      flake = false;
    };
  };

  outputs = {nixpkgs, nixpkgs-stable, flake-utils,
  grub2-themes, nix-alien, zhaith-neovim, hyprland, hyprland-contrib,
  sddm-sugar-candy-nix, virgutils, rofi-applets, ...}@attrs:
  let
    system = "x86_64-linux";
    customHelpers = import ./utils { inputs = attrs; };
    modules = import ./modules {};
  in
  {
    nixosConfigurations = {
      Whispering-Willow = customHelpers.mkSystem {
        inherit system;
        hostname = "Whispering-Willow";
        users = [ "zhaith" ];
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
          (final: prev: import ./overlay { inherit final prev; })
        ];
      };
      Ethereal-Edelweiss = customHelpers.mkSystem {
        inherit system;
        hostname = "Ethereal-Edelweiss";
        users = [ "lilith" ];
        nixpkgs = nixpkgs-stable;
        overlays = [
          (final: prev: {
            power-management = virgutils.packages.${system}.power-management;
          })
        ];
        extraModules = [
          grub2-themes.nixosModules.default
          modules.system
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
          modules.home-manager
          rofi-applets.homeManagerModules.default
        ];
        overlays = [
          hyprland.overlays.default
          hyprland-contrib.overlays.default
          virgutils.overlays.${system}.default
          rofi-applets.overlays.default
          (final: prev: import ./overlay { inherit final prev; })
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
  } // flake-utils.lib.eachDefaultSystem
  (system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
    docs = pkgs.callPackage ./modules/docs.nix {};
  in
  {
    # If you're not using NixOS and only want to load your home
    # configuration when `nix` is installed on your system and
    # flakes are enabled.
    #
    # Enable a `nix develop` shell with home-manager and git to
    # only load your home configuration.
    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        home-manager
        git
      ];
      NIX_CONFIG = "experimental-features = nix-command flakes";
    };
    packages = {
      docs = pkgs.callPackage ./mkDocs.nix { system-options-doc = docs; };
    };
  });
}

