{ config, pkgs, lib, inputs, theme, ... }:

let
  anyrun-plugins = inputs.anyrun.packages.${pkgs.system};
  hyprland-session = "hyprland-session.target";
in
{
  home.packages = with pkgs; [
    swww
    swayosd
  ] ++ theme.waybar-theme.extraPackages;

  gtk = {
    enable = true;
    inherit (theme.gtk-theme) theme cursorTheme iconTheme font;

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  services.dunst = {
    enable = true;
    inherit (theme.dunst-theme.dunst) iconTheme settings;
  };

  programs.anyrun = {
    enable = true;
    config = {
      plugins = with anyrun-plugins; [
        applications
        rink
        translate
        randr
        dictionary
      ];
      width = { fraction = 0.5; };
      height = { fraction = 0.5; };
      x = { fraction = 0.5; };
      y = { fraction = 0.5; };
      hideIcons = false;
      ignoreExclusiveZones = true;
      layer = "overlay";
      hidePluginInfo = true;
      closeOnClick = true;
      showResultsImmediately = true;
      maxEntries = 5;
    };
    extraCss = ''
      window:after {
        opacity: 0.5;
      }
    '';
    extraConfigFiles."applications.ron".text = ''
      Config(
        desktop_actions = true,
        max_entries = 5,
        terminal: Some("kitty"),
      )
    '';
  };

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    inherit (theme.swaylock-theme.swaylock) settings;
  };

  services.swayidle = {
    enable = true;
    systemdTarget = hyprland-session;
    timeouts = [
      {
        timeout = 270;
        command = "${lib.getExe pkgs.dim-on-lock} dim 50";
        resumeCommand = "${lib.getExe pkgs.dim-on-lock} undim";
      }
      { timeout = 300; command = "${lib.getExe config.programs.swaylock.package} -fF"; }
      {
        timeout = 360;
        command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
        resumeCommand = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      }
    ];
    events = [
      { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock -fF"; }
    ];
  };

  programs.waybar = {
    inherit (theme.waybar-theme.waybar) settings style;
    enable = true;
    package = pkgs.waybar-hyprland;
    systemd = {
      enable = true;
      target = hyprland-session;
    };
  };

  wayland.windowManager.hyprland = {
    inherit (theme.hyprland-theme.hyprland) extraConfig;
    enable = true;
    xwayland = {
      enable = true;
      hidpi = true;
    };
    systemdIntegration = true;
    recommendedEnvironment = true;
  };
}

