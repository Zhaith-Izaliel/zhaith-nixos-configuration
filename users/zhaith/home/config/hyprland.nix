{ common-attrs, ... }:

let
  gtk-theme = common-attrs.gtk-theme;
in
{
  imports = [
    ../../../../assets/hyprland/default.nix
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

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
      hidpi = true;
    };
    systemdIntegration = true;
    recommendedEnvironment = true;
    plugins = [

    ];
  };
}

