{ theme-packages }:

rec {

  package = theme-packages.gitui-theme;

  gitui = {
    theme = builtins.readFile "${package}/theme/macchiato.ron";
  };
}

