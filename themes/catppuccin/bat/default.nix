{ theme-packages }:

rec {

  package = theme-packages.bat-theme;

  bat = {
    themes = {
        catppuccin-macchiato = builtins.readFile
        "${package}/Catppuccin-macchiato.tmTheme";
    };
  };
}

