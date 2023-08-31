{ osConfig, config, lib, theme, pkgs, ... }:

with lib;

let
  converted-colors = attrsets.mapAttrs
  (name: value: strings.removePrefix "#" value)
  theme.colors;
  cfg = config.hellebore.desktop-environment.hyprland.swaylock;
in
  {
    options.hellebore.desktop-environment.hyprland.swaylock = {
      enable = mkEnableOption "Hellebore Swaylock and Swayidle configuration";
    };

    config = mkIf cfg.enable {
      assertions = [
        {
          assertion = cfg.enable -> config.wayland.windowManager.hyprland.enable;
          message = "Hyprland must be enabled for Swaylock and Swayidle to
          properly work";
        }
        {
          assertion = cfg.enable -> osConfig.hellebore.hyprland.enableSwaylockPam;
          message = "PAM service for Swaylock must be enabled to allow Swaylock
          to properly log you in.";
        }
      ];

      programs.swaylock = {
        enable = true;
        package = pkgs.swaylock-effects;
        settings = {
          indicator-radius = 100;
          color = converted-colors.base;
          bs-hl-color = converted-colors.rosewater;
          caps-lock-bs-hl-color = converted-colors.rosewater;
          caps-lock-key-hl-color = converted-colors.green;
          inside-color = converted-colors.base;
          inside-clear-color = converted-colors.base;
          inside-caps-lock-color = converted-colors.base;
          inside-ver-color = converted-colors.base;
          inside-wrong-color = converted-colors.base;
          key-hl-color = converted-colors.lavender;
          layout-bg-color = "00000000";
          layout-border-color = "00000000";
          layout-text-color = converted-colors.text;
          line-color = "00000000";
          line-clear-color = "00000000";
          line-caps-lock-color = "00000000";
          line-ver-color = "00000000";
          line-wrong-color = "00000000";
          ring-color = converted-colors.mauve;
          ring-clear-color = converted-colors.rosewater;
          ring-caps-lock-color = converted-colors.peach;
          ring-ver-color = converted-colors.blue;
          ring-wrong-color = converted-colors.maroon;
          separator-color = "00000000";
          text-color = converted-colors.text;
          text-clear-color = converted-colors.rosewater;
          text-caps-lock-color = converted-colors.peach;
          text-ver-color = converted-colors.blue;
          text-wrong-color = converted-colors.maroon;
          font-size = gtk-theme.font.size + 10;
          font = gtk-theme.font.name;
          indicator-caps-lock = true;
          clock = true;
          indicator = true;
          screenshots = true;
          effect-blur = "30x10";
          timestr = "%H:%M";
          datestr = "%d %b, %Y";
        };
      };

      services.swayidle = {
        enable = true;
        systemdTarget = "hyprland-session.target";
        timeouts = [
          {
            timeout = 270;
            command = "${getExe pkgs.dim-on-lock} dim 50";
            resumeCommand = "${getExe pkgs.dim-on-lock} undim";
          }
          { timeout = 300; command = "${getExe config.programs.swaylock.package} -fF"; }
          {
            timeout = 360;
            command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
            resumeCommand = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
          }
        ];
        events = [
          { event = "lock"; command = "${lib.getExe config.programs.swaylock.package} -fF"; }
        ];
      };
    };
  }

