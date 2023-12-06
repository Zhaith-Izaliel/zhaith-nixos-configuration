{ pkgs, lib }:
let
  theme-packages = import ./packages.nix { inherit pkgs lib; };
in
{
  bat = {
    package = theme-packages.bat-theme;
    src = theme-packages.bat-theme.src;
    name = "catppuccin-macchiato";
    file = "Catppuccin-macchiato.tmTheme";
  };

  gitui = rec {
    package = theme-packages.gitui-theme;
    file = "${package}/theme/macchiato.ron";
  };

  gtk = rec {
    inherit (theme-packages.gtk) configure-gtk theme cursorTheme iconTheme font;

    packages = [
      theme.package
      cursorTheme.package
      iconTheme.package
      font.package
      configure-gtk
      pkgs.gnome.gnome-themes-extra # Add default Gnome theme as well for Adwaita
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

