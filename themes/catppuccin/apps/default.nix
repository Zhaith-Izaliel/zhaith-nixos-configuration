{ pkgs, lib, inputs, colors }:

{
  bat = import ./bat.nix { inherit pkgs lib inputs; };
  fcitx5 = import ./fctix5.nix { inherit pkgs inputs; };
  gitui = import ./gitui.nix { inherit pkgs lib inputs; };
  gtk = import ./gtk.nix { inherit pkgs lib inputs; };
  hyprland = import ./hyprland.nix { inherit pkgs lib inputs; };
  starship = import ./starship.nix { inherit pkgs lib inputs colors; };
  kitty = import ./kitty.nix {};
  rofi = import ./rofi { inherit colors; };
}

