{ pkgs, lib, inputs }:
let
  colors = import ./colors.nix {};
  apps = import ./apps { inherit pkgs lib inputs colors; };
in
{
  inherit (apps) hyprland bat gitui gtk starship kitty fcitx5;
  inherit colors;

  rofi = {
    theme = {};

    applets = {
      vertical-theme = {};
      horizontal-theme = {};
    };
  };

}

