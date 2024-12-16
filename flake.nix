{
  description = "Zhaith's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    simple-nixos-mail-server = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    umu = {
      url = "git+https://github.com/Open-Wine-Components/umu-launcher/?dir=packaging\/nix&submodules=1";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    compose2nix = {
      url = "github:aksiksi/compose2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    grub2-themes = {
      url = "github:/vinceliuice/grub2-themes";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zhaith-helix = {
      url = "gitlab:Zhaith-Izaliel/helix-config/develop";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    sddm-sugar-candy-nix = {
      url = "gitlab:Zhaith-Izaliel/sddm-sugar-candy-nix/";
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
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # HACK: Using Wezterm nightly until they finish the wayland reimplementation and it's pushed to nixpkgs.
    wezterm = {
      url = "github:wez/wezterm/?dir=nix";
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

    catppuccin-yazi = {
      url = "github:catppuccin/yazi";
      flake = false;
    };
  };

  outputs = inputs @ {
    nixpkgs,
    grub2-themes,
    nix-alien,
    sddm-sugar-candy-nix,
    virgutils,
    rofi-applets,
    zhaith-helix,
    simple-nixos-mail-server,
    agenix,
    ...
  }: let
    inherit (import nixpkgs {inherit system;}) pkgs;
    system = "x86_64-linux";
    customHelpers = import ./utils/system.nix {inherit inputs;};
    modules = import ./modules {
      extraSystemModules = [
        grub2-themes.nixosModules.default
        sddm-sugar-candy-nix.nixosModules.default
        agenix.nixosModules.default
      ];

      extraHomeManagerModules = [
        zhaith-helix.homeManagerModules.default
        rofi-applets.homeManagerModules.default
        agenix.homeManagerModules.default
      ];

      extraServerModules = [
        simple-nixos-mail-server.nixosModules.default
      ];
    };
    customOverlay = import ./overlay {inherit inputs;};
    overlays = [
      nix-alien.overlays.default
      sddm-sugar-candy-nix.overlays.default
      virgutils.overlays.default
      agenix.overlays.default
      customOverlay
    ];
  in {
    nixosConfigurations = {
      Whispering-Willow = customHelpers.mkSystem {
        inherit system overlays;
        hostname = "Whispering-Willow";
        users = ["zhaith"];
        extraModules = [
          modules.system
          modules.server
        ];
      };
      Luminous-Rafflesia = customHelpers.mkSystem {
        inherit system overlays;
        hostname = "Luminous-Rafflesia";
        users = ["raphiel"];
        extraModules = [
          modules.system
          modules.server
        ];
      };
      Ethereal-Edelweiss = customHelpers.mkSystem {
        inherit system overlays;
        hostname = "Ethereal-Edelweiss";
        users = ["lilith"];
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
        stateVersion = "24.11";
      };

      "raphiel@Luminous-Rafflesia" = customHelpers.mkHome {
        inherit system overlays extraModules;
        username = "raphiel";
        hostname = "Luminous-Rafflesia";
        stateVersion = "24.11";
      };

      "lilith@Ethereal-Edelweiss" = customHelpers.mkHome {
        inherit system overlays extraModules;
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
