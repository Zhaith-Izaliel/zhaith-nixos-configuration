{ pkgs, lib }:
let
  theme-packages = import ./packages.nix { inherit pkgs lib; };
in
{
  bat = rec {
    package = theme-packages.bat-theme;
    name = "catppuccin-macchiato";
    file = "${package}/Catppuccin-macchiato.tmTheme";
  };

  gitui = rec {
    package = theme-packages.gitui-theme;
    file = "${package}/theme/macchiato.ron";
  };

  gtk = rec {
    inherit (theme-packages.gtk) theme cursorTheme iconTheme font;

    packages = [
      theme.package
      cursorTheme.package
      iconTheme.package
      font.package
    ];
  };

  starship = rec {
    package = theme-packages.starship-palette;
    paletteName = "catppuccin_macchiato";
    palette = builtins.fromTOML (builtins.readFile (package +
    /palettes/macchiato.toml));
  };

  hyprland = rec {
    package = theme-packages.hyprland-palette;
    palette = "${package}/themes/macchiato.conf";
  };

  fcitx5 = {
    package = theme-packages.fcitx5-theme;
    name = "catppuccin-macchiato";
  };

  kitty.theme = "Catppuccin-Macchiato";

  colors = import ./colors.nix {};
}

