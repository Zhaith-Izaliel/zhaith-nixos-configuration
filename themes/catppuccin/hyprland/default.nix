{ theme-packages, gtk-theme }:

let
  hyprland-conf = builtins.readFile ./hyprland.conf;
in
rec {
  package = theme-packages.hyprland-palette;
  palette = "${package}/themes/macchiato.conf";

  hyprland = {
    extraConfig = ''
    source = ${palette}
    exec-once = hyprctl setcursor ${gtk-theme.cursorTheme.name} 24

    '' + hyprland-conf;
  };
}

