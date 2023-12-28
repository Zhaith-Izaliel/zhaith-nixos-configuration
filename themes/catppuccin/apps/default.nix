{ pkgs, lib, inputs, colors }:

{
  bat = import ./bat.nix { inherit pkgs lib inputs; };
  dunst = import ./dunst.nix { inherit lib colors; };
  fcitx5 = import ./fctix5.nix { inherit pkgs inputs colors; };
  gitui = import ./gitui.nix { inherit pkgs lib inputs; };
  gtk = import ./gtk.nix { inherit pkgs lib inputs; };
  hyprland = import ./hyprland.nix { inherit pkgs lib inputs; };
  starship = import ./starship.nix { inherit pkgs lib inputs colors; };
  kitty = import ./kitty.nix {};
  rofi = import ./rofi { inherit colors; };
  sddm = import ./sddm.nix { inherit colors; };
  shell = import ./shell.nix { inherit colors; };
  swaylock = import ./swaylock.nix { inherit colors; };
  waybar = { config, cfg, os-config }: import ./waybar {
    inherit config cfg os-config colors pkgs lib;
  };
  wlogout = import ./wlogout.nix { inherit colors lib; };
}

