{ config, pkgs, ... }:

{
  gtk = {
    enable = true;

    theme = {
      name = "Catppuccin-Dark";
      package = pkgs.catppuccin-gtk;
    };

    cursorTheme = {
      name = "Catppuccin-Macchiato-Dark-Cursors";
      package = pkgs.catppuccin-cursors.macchiatoDark;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    font = {
      package = pkgs.cantarell-fonts;
      name = "Cantarell Regular";
      size = 14;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  home.packages = with pkgs.gnomeExtensions; [
    appindicator
    espresso
    clipboard-indicator
    color-picker
    customize-ibus
    just-perfection
    places-status-indicator
    workspace-indicator
  ];
}