{ config, pkgs, ...}:

let
  erdConfig = ''
    # Human readable sizes
    --human

    # Inverted tree
    --inverted

    # Using Icons
    --icons
  '';
in
{
  home.file."${config.xdg.configHome}/erdtree/.erdtreerc".text = erdConfig;
}
