{
  description = "Zhaith's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
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
    anyrun.url = "github:Kirottu/anyrun";
    hyprland-contrib.url = "github:hyprwm/contrib";
    sddm-sugar-candy-nix.url = "gitlab:Zhaith-Izaliel/sddm-sugar-candy-nix";
  };

  outputs = {nixpkgs, nixpkgs-stable, home-manager-stable, flake-utils,
  grub2-themes, nix-alien, zhaith-neovim, hyprland, anyrun, hyprland-contrib,
  sddm-sugar-candy-nix, ...}@attrs:
  let
    system = "x86_64-linux";
    theme = "catppuccin";
    lib = import ./lib { inputs = attrs; };
    modules = import ./modules {};
  in
  {
    nixosConfigurations = {
      Whispering-Willow = lib.mkSystem {
        inherit system theme;
        hostname = "Whispering-Willow";
        users = [ "zhaith" ];
        extraModules = [
          hyprland.nixosModules.default
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
      Ethereal-Edelweiss = lib.mkSystem {
        inherit system theme;
        nixpkgs = nixpkgs-stable;
        hostname = "Ethereal-Edelweiss";
        users = [ "lilith" ];
        extraModules = [
          grub2-themes.nixosModules.default
          modules.system
        ];
      };
    };
    homeConfigurations = {
      "zhaith@Whispering-Willow" = lib.mkHome {
        inherit system theme;
        username = "zhaith";
        hostname = "Whispering-Willow";
        stateVersion = "22.05";
        extraModules = [
          zhaith-neovim.nixosModules.default
          hyprland.homeManagerModules.default
          anyrun.homeManagerModules.default
          modules.home-manager
        ];
        overlays = [
          hyprland.overlays.default
          hyprland-contrib.overlays.default
          (final: prev: import ./overlay { inherit final prev; })
        ];
      };

      "lilith@Ethereal-Edelweiss" = lib.mkHome {
        inherit system theme;
        home-manager = home-manager-stable;
        nixpkgs = nixpkgs-stable;
        username = "lilith";
        hostname = "Ethereal-Edelweiss";
        stateVersion = "21.05";
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

