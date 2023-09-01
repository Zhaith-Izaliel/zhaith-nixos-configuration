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
    theme = {
      name = "Catppuccin-Macchiato-Standard-Sapphire-Dark";
      package = theme-packages.gtk.theme;
    };

    cursorTheme = {
      name = "Catppuccin-Macchiato-Dark-Cursors";
      package = theme-packages.gtk.cursors;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = theme-packages.gtk.icons;
    };

    font = {
      package = theme-packages.gtk.font;
      name = "Cantarell";
      size = 14;
    };

    packages = [
      theme.package
      cursorTheme.package
      iconTheme.package
      font.package
    ];
  };

  starship = rec {
    package = theme-packages.starship-palette;
    paletteName = "macchiato";
    palette = builtins.fromTOML (builtins.readFile (package +
    /palettes/${paletteName}.toml));
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

