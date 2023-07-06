{ pkgs, inputs, common-attrs, ... }:

let
  gtk-theme = common-attrs.gtk-theme;
  hyprland-config = import  ../../../../assets/hyprland/default.nix { inherit pkgs; };
  anyrun-plugins = inputs.anyrun.packages.${pkgs.system};
in
{
  home.packages = with pkgs; [
    xdg-desktop-portal-hyprland
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

  programs.anyrun = {
    enable = true;
    config = {
      plugins = with anyrun-plugins; [
        applications
        symbols
        rink
        shell
        translate
        randr
        stdin
        dictionary
      ];
      width = { fraction = 0.5; };
      height = { fraction = 0.5; };
      hideIcons = false;
      ignoreExclusiveZones = false;
      layer = "top";
      hidePluginInfo = false;
      closeOnClick = false;
      showResultsImmediately = false;
      maxEntries = null;
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
      hidpi = true;
    };
    systemdIntegration = true;
    recommendedEnvironment = true;
    plugins = with pkgs; [
    ];
    extraConfig = hyprland-config.config;
  };
}

