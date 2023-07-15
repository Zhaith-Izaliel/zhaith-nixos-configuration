{ pkgs, lib }:

let
  theme-packages = import ./packages.nix { inherit lib pkgs; };
in
rec {
  packages = theme-packages.all;

  colors = import ./colors.nix {};

  gtk-theme = import ./gtk { inherit theme-packages; };

  swaylock-theme = import ./swaylock { inherit colors gtk-theme theme-packages lib; };

  dunst-theme = import ./dunst { inherit colors gtk-theme; };

  starship-theme = import ./starship { inherit colors theme-packages lib; };

  regreet-theme = import ./regreet { inherit gtk-theme lib; };

  sddm-theme = import ./sddm { inherit theme-packages; };

  hyprland-theme = import ./hyprland { inherit gtk-theme theme-packages; };

  bat-theme = import ./bat { inherit theme-packages; };

  gitui-theme = import ./gitui { inherit theme-packages; };

  waybar-theme = import ./waybar { inherit pkgs lib colors; };

  fcitx5-theme = import ./fcitx5 { inherit theme-packages; };
}

