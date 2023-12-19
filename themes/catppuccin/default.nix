{ pkgs, lib, inputs }:
let
  theme-packages = import ./packages.nix { inherit pkgs lib; };
  apps = import ./apps { inherit pkgs lib inputs; };
in
{
  inherit (apps) hyprland bat gitui gtk;

  starship = rec {
    package = theme-packages.starship-palette;
    paletteName = "catppuccin_macchiato";
    palette = builtins.fromTOML (builtins.readFile (package +
    /palettes/macchiato.toml));
  };

  fcitx5 = {
    package = theme-packages.fcitx5-theme;
    name = "catppuccin-macchiato";
  };

  kitty.theme = "Catppuccin-Macchiato";

  rofi = {
    theme = {};

    applets = {
      vertical-theme = {};
      horizontal-theme = {};
    };
  };

  colors = import ./colors.nix {};
}

