{ pkgs, lib }:

let
  hyprland-conf = builtins.readFile ./hyprland.conf;
  catppuccin-colors-hyprland = (import ../../theme { inherit pkgs lib;
}).hyprland-theme.palette;
in
{
  config = ''
  source = ${catppuccin-colors-hyprland}

  '' + hyprland-conf;
}

