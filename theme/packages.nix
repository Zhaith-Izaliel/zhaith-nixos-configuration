{ pkgs, lib }:

let
  default = {
    starship-palette = pkgs.stdenv.mkDerivation {
      pname = "starship-palette";
      version = "3e3e544";
      src = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "starship";
        rev = "3e3e544"; # Replace with the latest commit hash
        sha256 = "sha256-soEBVlq3ULeiZFAdQYMRFuswIIhI9bclIU8WXjxd7oY=";
      };

      installPhase = ''
      mkdir -p $out
      cp -r palettes $out
      '';
    };

    gtk = pkgs.catppuccin-gtk.override {
      accents = [ "blue" "flamingo" "green" "lavender" "maroon" "mauve" "peach"
      "pink" "red" "rosewater" "sapphire" "sky" "teal" "yellow" ];
      size = "standard";
      variant = "macchiato";
    };

    cursors = pkgs.catppuccin-cursors.macchiatoDark;

    icons = pkgs.papirus-icon-theme;

    font = pkgs.cantarell-fonts;

    hyprland-palette = pkgs.stdenv.mkDerivation rec {
      name = "catppucin-hyprland";
      version = "1.2";

      src = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "hyprland";
        rev  = "v${version}";
        sha256 = "sha256-07B5QmQmsUKYf38oWU3+2C6KO4JvinuTwmW1Pfk8CT8=";
      };

      installPhase = ''
      mkdir -p $out
      cp -r themes $out
      '';
    };

    bat-theme = pkgs.stdenv.mkDerivation rec {
      pname = "bat-catppuccin";
      version  = "ba4d168";

      src = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "bat"; # Bat uses sublime syntax for its themes
        rev = version;
        sha256 = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
      };

      installPhase = ''
      mkdir -p $out
      cp -r *.tmTheme $out
      '';
    };

    gitui-theme = pkgs.stdenv.mkDerivation rec {
      pname = "gitui-catppuccin";
      version  = "3c97c7a";

      src = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "gitui"; # Bat uses sublime syntax for its themes
        rev = version;
        sha256 = "";
      };

      installPhase = ''
      mkdir -p $out
      cp -r theme $out
      '';
    };
  };
in
  default // {
    all = lib.attrsets.mapAttrsToList (name: value: value) default;
  }

