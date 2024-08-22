{
  pkgs,
  lib,
  inputs,
  colors,
  extra-utils,
}: rec {
  bat = import ./bat.nix {inherit pkgs lib inputs;};
  contour = import ./contour.nix {inherit colors;};
  dunst = import ./dunst.nix {inherit colors;};
  fcitx5 = import ./fctix5.nix {inherit pkgs inputs colors;};
  gitui = import ./gitui.nix {inherit pkgs lib inputs;};
  gtk = import ./gtk.nix {inherit pkgs lib;};
  hyprland = import ./hyprland.nix {inherit pkgs lib inputs;};
  hyprlock = import ./hyprlock.nix {
    inherit colors lib pkgs;
    inherit (hyprland) palette;
  };
  starship = import ./starship.nix {inherit pkgs lib inputs colors;};
  rofi = mkLiteral: import ./rofi {inherit colors mkLiteral;};
  sddm = import ./sddm.nix {inherit colors;};
  shell = import ./shell.nix {inherit colors;};
  waybar = modules: import ./waybar {inherit colors inputs modules lib extra-utils;};
  wezterm = import ./wezterm.nix {};
  wlogout = import ./wlogout {inherit colors lib;};
  yazi = import ./yazi.nix {inherit inputs pkgs bat;};
  zellij = import ./zellij.nix {};
}
