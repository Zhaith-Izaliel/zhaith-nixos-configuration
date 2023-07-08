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
  };
in
  default // {
    all = lib.attrsets.mapAttrsToList (name: value: value) default; # TODO: map all attributes to this list.
  }

