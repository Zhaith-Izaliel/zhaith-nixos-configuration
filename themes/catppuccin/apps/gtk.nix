{ pkgs, lib, inputs }:

rec {
  theme = {
    package = pkgs.catppuccin-gtk.override {
      accents = [ "blue" "flamingo" "green" "lavender" "maroon" "mauve" "peach"
      "pink" "red" "rosewater" "sapphire" "sky" "teal" "yellow" ];
      size = "standard";
      variant = "macchiato";
    };
    name = "Catppuccin-Macchiato-Standard-Lavender-Dark";
  };

  cursorTheme = {
    package = pkgs.catppuccin-cursors.macchiatoDark;
    name = "Catppuccin-Macchiato-Dark-Cursors";
  };

  iconTheme = {
    package = pkgs.papirus-icon-theme;
    name = "Papirus-Dark";
  };

  font = {
    package = pkgs.cantarell-fonts;
    name = "Cantarell";
  };

  packages = [
    theme.package
    cursorTheme.package
    iconTheme.package
    font.package
  ];
}

