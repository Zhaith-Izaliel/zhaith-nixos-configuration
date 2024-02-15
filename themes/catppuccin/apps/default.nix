{
  pkgs,
  lib,
  inputs,
  colors,
}: {
  alacritty = import ./alacritty {inherit pkgs inputs;};
  bat = import ./bat.nix {inherit pkgs lib inputs;};
  dunst = import ./dunst.nix {inherit colors;};
  fcitx5 = import ./fctix5.nix {inherit pkgs inputs colors;};
  gitui = import ./gitui.nix {inherit pkgs lib inputs;};
  gtk = import ./gtk.nix {inherit pkgs lib;};
  hyprland = import ./hyprland.nix {inherit pkgs lib inputs;};
  starship = import ./starship.nix {inherit pkgs lib inputs colors;};
  kitty = import ./kitty.nix {};
  rofi = mkLiteral: import ./rofi {inherit colors mkLiteral;};
  sddm = import ./sddm.nix {inherit colors;};
  shell = import ./shell.nix {inherit colors;};
  swaylock = import ./swaylock.nix {inherit lib colors;};
  waybar = modules: import ./waybar {inherit colors inputs modules lib;};
  wlogout = import ./wlogout.nix {inherit colors lib;};
}
