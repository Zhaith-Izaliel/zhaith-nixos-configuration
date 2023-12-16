{ os-config, config, lib, theme, pkgs, extra-types, ... }:

with lib;

let
  converted-colors = attrsets.mapAttrs
  (name: value: strings.removePrefix "#" value)
  theme.colors;
  cfg = config.hellebore.desktop-environment.hyprland.lockscreen;
in
  {
    options.hellebore.desktop-environment.hyprland.lockscreen = {
      enable = mkEnableOption "Hellebore Swaylock and Swayidle configuration";

      fontSize = extra-types.fontSize {
        default = config.hellebore.font.size;
        description = "Set lockscreen font size.";
      };

      indicatorRadius = mkOption {
        type = types.int;
        default = 100;
        description = "Set the indicator radius";
      };

      gracePeriod = mkOption {
        type = types.ints.unsigned;
        default = 15;
        description = "The grace period during which you can unlock without a
        password, in seconds.";
      };

      timeouts = {
        dim = {
          enable = mkEnableOption "Dim Screen timeout";

          dimValue = mkOption {
            type = types.numbers.between 0 100;
            default = 50;
            description = "The dim value applied to the brightness of the
            screen, can be between 0 and 100 inclusive.";
          };

          timer = mkOption {
            type = types.ints.unsigned;
            default = 270;
            description = "The time of inactivity before dimming the screen, in
            seconds.";
          };
        };

        lock = {
          enable = mkEnableOption "Lock Screen timeout";

          timer = mkOption {
            type = types.ints.unsigned;
            default = 300;
            description = "The time of inactivity before locking the screen, in
            seconds.";
          };
        };

        powerSaving = {
          enable = mkEnableOption "Power Saving timeout";

          timer = mkOption {
            type = types.ints.unsigned;
            default = 360;
            description = "The time of inactivity before shutting down the
            screen, in seconds.";
          };
        };
      };
    };

    config = mkIf cfg.enable {
      assertions = [
        {
          assertion = cfg.enable -> config.wayland.windowManager.hyprland.enable;
          message = "Hyprland must be enabled for Swaylock and Swayidle to
          properly work";
        }
        {
          assertion = cfg.enable -> os-config.hellebore.hyprland.enableSwaylockPam;
          message = "PAM service for Swaylock must be enabled to allow Swaylock
          to properly log you in.";
        }
        {
          assertion = cfg.enable ->
            cfg.timeouts.dim.timer < cfg.timeouts.lock.timer &&
            cfg.timeouts.lock.timer < cfg.timeouts.powerSaving.timer;
          message = "Your timers should be in ascending order, such that
          `dim.timer < lock.timer < powerSaving.timer`";
        }
      ];

      programs.swaylock = {
        enable = true;
        package = pkgs.swaylock-effects;
        settings = {
          grace = cfg.gracePeriod;
          indicator-radius = cfg.indicatorRadius;
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
          font-size = cfg.fontSize;
          font = theme.gtk.font.name;
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
          (mkIf cfg.timeouts.dim.enable {
            timeout = cfg.timeouts.dim.timer;
            command = "${getExe pkgs.dim-on-lock} dim ${toString cfg.timeouts.dim.dimValue}";
            resumeCommand = "${getExe pkgs.dim-on-lock} undim";
          })

          (mkIf cfg.timeouts.lock.enable {
            timeout = cfg.timeouts.lock.timer;
            command = "${getExe config.programs.swaylock.package} -fF";
          })

          (mkIf cfg.timeouts.powerSaving.enable {
            timeout = cfg.timeouts.powerSaving.timer;
            command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
            resumeCommand = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
          })
        ];
        events = [
          { event = "lock"; command = "${lib.getExe config.programs.swaylock.package} -fF"; }
        ];
      };
    };
  }

