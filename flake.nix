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
    grub2-themes.url = "github:/vinceliuice/grub2-themes";
    nix-alien.url = "github:thiagokokada/nix-alien";
    zhaith-neovim.url = "gitlab:Zhaith-Izaliel/neovim-config/develop";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-contrib.url = "github:hyprwm/contrib";
    sddm-sugar-candy-nix.url = "gitlab:Zhaith-Izaliel/sddm-sugar-candy-nix";
  };

  outputs = {nixpkgs, nixpkgs-stable, flake-utils,
  grub2-themes, nix-alien, zhaith-neovim, hyprland, hyprland-contrib,
  sddm-sugar-candy-nix, ...}@attrs:
  let
    system = "x86_64-linux";
    theme = "catppuccin";
    customHelpers = import ./lib { inputs = attrs; };
    modules = import ./modules {};
  in
  {
    nixosConfigurations = {
      Whispering-Willow = customHelpers.mkSystem {
        inherit system theme;
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
          (final: prev: import ./overlay { inherit final prev; })
        ];
      };
      Ethereal-Edelweiss = customHelpers.mkSystem {
        inherit system theme;
        hostname = "Ethereal-Edelweiss";
        users = [ "lilith" ];
        nixpkgs = nixpkgs-stable;
        extraModules = [
          grub2-themes.nixosModules.default
          modules.system
        ];
      };
    };
    homeConfigurations = {
      "zhaith@Whispering-Willow" = customHelpers.mkHome {
        inherit system theme;
        username = "zhaith";
        hostname = "Whispering-Willow";
        stateVersion = "22.05";
        extraModules = [
          zhaith-neovim.homeManagerModules.default
          hyprland.homeManagerModules.default
          modules.home-manager
        ];
        overlays = [
          hyprland.overlays.default
          hyprland-contrib.overlays.default
          (final: prev: import ./overlay { inherit final prev; })
        ];
      };

      "lilith@Ethereal-Edelweiss" = customHelpers.mkHome {
        inherit system theme;
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
  in
  {
    # If you're not using NixOS and only want to load your home
    # configuration when `nix` is installed on your system and
    # flakes are enabled.
    #
    # Enable a `nix develop` shell with home-manager and git to
    # only load your home configuration.
    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [ home-manager git ];
      NIX_CONFIG = "experimental-features = nix-command flakes";
    };
  });
}

