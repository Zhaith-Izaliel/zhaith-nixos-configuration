{ pkgs, lib }:

let
  hyprland-conf = builtins.readFile ./hyprland.conf;
  theme = import ../../theme { inherit pkgs lib; };
in
{
  config = ''
  source = ${theme.hyprland-theme.palette}
  exec-once = hyprctl setcursor ${theme.gtk-theme.cursorTheme.name} 24

  '' + hyprland-conf;
}

