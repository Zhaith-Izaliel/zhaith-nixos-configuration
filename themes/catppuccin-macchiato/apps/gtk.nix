{
  pkgs,
  lib,
}: rec {
  theme = {
    package = pkgs.catppuccin-gtk.override {
      accents = [
        "blue"
        "flamingo"
        "green"
        "lavender"
        "maroon"
        "mauve"
        "peach"
        "pink"
        "red"
        "rosewater"
        "sapphire"
        "sky"
        "teal"
        "yellow"
      ];
      size = "standard";
      variant = "macchiato";
    };
    name = "catppuccin-macchiato-lavender-standard+default";
  };

  cursorTheme = {
    package = pkgs.catppuccin-cursors.macchiatoDark;
    name = "catppuccin-macchiato-dark-cursors";
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
