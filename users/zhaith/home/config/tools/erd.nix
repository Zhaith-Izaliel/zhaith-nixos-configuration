{ config, pkgs, ...}:

let
  erdConfig = ''
    # Human readable sizes
    --human

    # Inverted tree
    --inverted

    # Using Icons
    --icons

    # Sort
    --dirs-first
    --sort name
  '';
in
{
  home.file."${config.xdg.configHome}/erdtree/.erdtreerc".text = erdConfig;
}
