{ pkgs, common-attrs, ... }:

let
  gtk-theme = common-attrs.gtk-theme;
  hyprland-config = import  ../../../../assets/hyprland/default.nix { inherit pkgs; };
in
{
  home.packages = with pkgs; [
  ];

  gtk = {
    enable = true;
    inherit (gtk-theme) theme cursorTheme iconTheme font;

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  services.dunst = {
    enable = true;
    inherit (gtk-theme) iconTheme;
  };

  programs.wofi = {
    enable = true;
    style = hyprland-config.wofi-theme;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
      hidpi = false;
    };
    systemdIntegration = true;
    recommendedEnvironment = true;
    plugins = with pkgs; [
      waybar-hyprland
    ];
    extraConfig = hyprland-config.config;
  };
}

