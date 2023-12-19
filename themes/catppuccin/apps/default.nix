{ pkgs, lib, inputs }:

{
  hyprland = import ./hyprland.nix { inherit pkgs lib inputs; };
  gitui = import ./gitui.nix { inherit pkgs lib inputs; };
  bat = import ./bat.nix { inherit pkgs lib inputs; };
}

