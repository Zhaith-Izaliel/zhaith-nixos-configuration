{
  os-config,
  config,
  lib,
  pkgs,
  extra-types,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf types getExe mkPackageOption;
  cfg = config.hellebore.desktop-environment.lockscreen;
  theme = config.hellebore.theme.themes.${cfg.theme};
in {
  options.hellebore.desktop-environment.lockscreen = {
    enable = mkEnableOption "Hellebore Swaylock and Swayidle configuration";

    font = extra-types.font {
      inherit (config.hellebore.font) size name;
      sizeDescription = "Set lockscreen font size.";
      nameDescription = "Set lockscreen font family.";
    };

    theme = extra-types.theme.name {
      default = config.hellebore.theme.name;
      description = "Defines the lockscreen theme.";
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

    package = mkPackageOption pkgs "swaylock-effects" {};

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
        assertion =
          cfg.enable
          -> cfg.timeouts.dim.timer
          < cfg.timeouts.lock.timer
          && cfg.timeouts.lock.timer < cfg.timeouts.powerSaving.timer;
        message = "Your timers should be in ascending order, such that
        `dim.timer < lock.timer < powerSaving.timer`";
      }
    ];

    programs.swaylock = {
      inherit (cfg) package;
      enable = true;
      settings =
        {
          indicator-radius = cfg.indicatorRadius;
          font-size = cfg.font.size;
          font = cfg.font.name;
        }
        // theme.swaylock.settings;
    };

    services.hypridle = {
      enable = true;
      listeners = [
        (mkIf cfg.timeouts.dim.enable {
          timeout = cfg.timeouts.dim.timer;
          onTimeout = "${getExe pkgs.dim-on-lock} dim ${toString cfg.timeouts.dim.dimValue}";
          onResume = "${getExe pkgs.dim-on-lock} undim";
        })

        (mkIf cfg.timeouts.lock.enable {
          timeout = cfg.timeouts.lock.timer;
          onTimeout = "${getExe config.programs.swaylock.package} -fF --grace ${toString cfg.gracePeriod}";
        })

        (mkIf cfg.timeouts.powerSaving.enable {
          timeout = cfg.timeouts.powerSaving.timer;
          onTimeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
          onResume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
        })
      ];
    };
  };
}
