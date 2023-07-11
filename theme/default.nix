{ pkgs, lib }:

let
  theme-packages = import ./packages.nix { inherit lib pkgs; };
in
rec {
  packages = theme-packages.all;

  colors = import ./colors.nix {};

  gtk-theme = import ./gtk.nix { inherit theme-packages; };

  swaylock-theme = import ./swaylock.nix { inherit colors theme-packages lib; };

  dunst-theme = import ./dunst.nix { inherit colors theme-packages; };

  starship-theme = import ./starship.nix { inherit colors pkgs lib; };

  regreet-theme = import ./regreet.nix { inherit gtk-theme lib; };

  hyprland-theme = rec {
    package = theme-packages.hyprland-palette;
    palette = "${package}/themes/macchiato.conf";
  };

  bat-theme = import ./bat.nix { inherit theme-packages; };

  gitui-theme = import ./gitui.nix { inherit theme-packages; };

  waybar-theme = import ./waybar.nix { inherit pkgs colors; };
}

