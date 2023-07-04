{ pkgs }:

let
  default = {
    theme = {
      name = "Catppuccin-Macchiato-Standard-Sapphire-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" "flamingo" "green" "lavender" "maroon" "mauve" "peach"
        "pink" "red" "rosewater" "sapphire" "sky" "teal" "yellow" ];
        size = "standard";
        variant = "macchiato";
      };
    };

    cursorTheme = {
      name = "Catppuccin-Macchiato-Dark-Cursors";
      package = pkgs.catppuccin-cursors.macchiatoDark;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    font = {
      package = pkgs.cantarell-fonts;
      name = "Cantarell";
      size = 14;
    };
  };
in
  default // {
    packages = [
      default.theme.package
      default.cursorTheme.package
      default.iconTheme.package
      default.font.package
    ];
  }

