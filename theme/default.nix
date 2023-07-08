{ pkgs, lib }:

let
  theme-packages = import ./packages.nix { inherit lib pkgs; };
in
rec {
  packages = theme-packages.all;

  colors = import ./colors;

  gtk-theme = import ./gtk.nix { inherit theme-packages; };

  swaylock-theme = import ./swaylock.nix { inherit colors theme-packages lib; };

  dunst-theme = import ./dunst.nix { inherit theme-packages pkgs; };

  starship-theme = import ./starship.nix { inherit colors pkgs lib; };

  hyprland-theme = rec {
    package = theme-packages.hyprland-palette;
    palette = "${package}/themes/macchiato.conf";
  };
}

