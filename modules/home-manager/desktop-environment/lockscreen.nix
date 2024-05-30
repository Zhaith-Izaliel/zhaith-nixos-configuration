{
  os-config,
  options,
  config,
  lib,
  pkgs,
  extra-types,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf types getExe mkPackageOption optionalAttrs;
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

    bin = mkOption {
      readOnly = true;
      type = types.nonEmptyStr;
      default = "${getExe cfg.package} -fF";
      description = "Defines the command used for locking the screen. Read-only.";
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

  config = mkIf cfg.enable ({
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
    }
    # COMPATIBILITY: Unallow Hypridle with 23.11
    // optionalAttrs (builtins.hasAttr "hypridle" options.services) {
      services.hypridle = {
        enable = true;
        settings = {
          listeners = [
            (optionalAttrs cfg.timeouts.dim.enable {
              timeout = cfg.timeouts.dim.timer;
              onTimeout = "${getExe pkgs.dim-on-lock} --dim ${toString cfg.timeouts.dim.dimValue}";
              onResume = "${getExe pkgs.dim-on-lock} --undim";
            })

            (optionalAttrs cfg.timeouts.lock.enable {
              timeout = cfg.timeouts.lock.timer;
              onTimeout = "${cfg.bin} --grace ${toString cfg.gracePeriod}";
            })

            (optionalAttrs cfg.timeouts.powerSaving.enable {
              timeout = cfg.timeouts.powerSaving.timer;
              onTimeout = "${getExe pkgs.dim-on-lock} --undim && ${getExe pkgs.dim-on-lock} --no-min --dim 100";
              onResume = "${getExe pkgs.dim-on-lock} --undim";
            })
          ];
        };
      };
    });
}
