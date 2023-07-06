{ pkgs }:

let
  hyprland-conf = builtins.readFile ./hyprland.conf;
  catppuccin-colors-hyprland = import ./colors.nix { inherit pkgs; };
  catppuccin-colors-wofi = import ./wofi-style { inherit pkgs; };
in
{
  config = ''
  source = ${catppuccin-colors-hyprland}/themes/macchiato.conf

  '' + hyprland-conf;

  wofi-theme =  builtins.readFile
  "${catppuccin-colors-wofi}/src/macchiato/sapphire/style.css";
}

