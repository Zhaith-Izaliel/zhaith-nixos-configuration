{ theme-packages }:

rec {
  theme = {
    name = "Catppuccin-Macchiato-Standard-Sapphire-Dark";
    package = theme-packages.gtk;
  };

  cursorTheme = {
    name = "Catppuccin-Macchiato-Dark-Cursors";
    package = theme-packages.cursors;
  };

  iconTheme = {
    name = "Papirus-Dark";
    package = theme-packages.icons;
  };

  font = {
    package = theme-packages.font;
    name = "Cantarell";
    size = 14;
  };
  packages = [
    theme.package
    cursorTheme.package
    iconTheme.package
    font.package
  ];
}

