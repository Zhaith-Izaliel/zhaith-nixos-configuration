{ config, pkgs, ...}:

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
  home.file."${config.xdg.configHome}/erdtree/.erdtreerc".text = erdConfig;
}

