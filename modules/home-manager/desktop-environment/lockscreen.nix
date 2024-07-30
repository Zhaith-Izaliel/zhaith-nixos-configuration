{
  os-config,
  config,
  lib,
  pkgs,
  extra-types,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf types getExe mkPackageOption optional sort compareLists flatten concatStringsSep mapAttrsToList;
  cfg = config.hellebore.desktop-environment.lockscreen;
  theme = config.hellebore.theme.themes.${cfg.theme};

  listener = flatten [
    (optional cfg.timeouts.dim.enable {
      timeout = cfg.timeouts.dim.timer;
      on-timeout = "${getExe pkgs.dim-on-lock} --dim ${toString cfg.timeouts.dim.dimValue}";
      on-resume = "${getExe pkgs.dim-on-lock} --undim";
    })
    (optional cfg.timeouts.lock.enable {
      timeout = cfg.timeouts.lock.timer;
      on-timeout = "loginctl lock-session";
    })

    (optional cfg.timeouts.keyboard-backlight.enable {
      timeout = cfg.timeouts.keyboard-backlight.timer;
      on-timeout = "brightnessctl -sd rgb:kbd_backlight set 0";
      on-resume = "brightnessctl -rd rgb:kbd_backlight";
    })

    (optional cfg.timeouts.powerSaving.enable {
      timeout = cfg.timeouts.powerSaving.timer;
      on-timeout = "hyprctl dispatch dpms off";
      on-resume = "hyprctl dispatch dpms on";
    })

    (optional cfg.timeouts.suspend.enable {
      timeout = cfg.timeouts.suspend.timer;
      on-timeout = "systemctl suspend";
    })
  ];

  areListenersInOrder = compareLists (a: b: a.on-timeout == b.on-timeout) (sort (a: b: a.timeout <= b.timeout) listener) listener;
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

      keyboard-backlight = {
        enable = mkEnableOption "Keyboard Backlight timeout";

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

      suspend = {
        enable = mkEnableOption "Suspend timeout";

        timer = mkOption {
          type = types.ints.unsigned;
          default = 1800;
          description = "The time of inactivity before shutting down the
          screen, in seconds.";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.wayland.windowManager.hyprland.enable;
        message = "Hyprland must be enabled for Swaylock and Hypridle to
        properly work";
      }
      {
        assertion = os-config.hellebore.hyprland.enableSwaylockPam;
        message = "PAM service for Swaylock must be enabled to allow Swaylock
        to properly log you in.";
      }
      {
        assertion = areListenersInOrder;
        message = ''
          Your timers should be in ascending order, such as
          `${concatStringsSep " <= " (mapAttrsToList (name: value: "${name}.timer") cfg.timeouts)}`
        '';
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
      settings = {
        inherit listener;
        general = {
          lock_cmd = "pidof hyprlock || ${cfg.bin} --grace ${toString cfg.gracePeriod}";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };
      };
    };
  };
}
