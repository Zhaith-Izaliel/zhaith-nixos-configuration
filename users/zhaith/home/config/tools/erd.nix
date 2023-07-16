{ config, unstable-pkgs, ...}:

let
  erdConfig = ''
    # Human readable sizes
    --human

    # Inverted tree
    --layout inverted

    # Using Icons
    --icons

    # Sort
    --dir-order first
    --sort name
  '';
in
{
  home.packages = [
    unstable-pkgs.erdtree
  ];

  home.file."${config.xdg.configHome}/erdtree/.erdtreerc".text = erdConfig;
}

