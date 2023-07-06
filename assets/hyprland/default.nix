{ pkgs, ... }:

let
  hyprland-conf = builtins.readFile ./hyprland.conf;
  catppuccin-colors-hyprland = import ./colors.nix { inherit pkgs; };
in
{
  wayland.windowManager.hyprland.config = ''
    source = ${catppuccin-colors-hyprland}/themes/macchiato.conf

  '' + hyprland-conf;
}

