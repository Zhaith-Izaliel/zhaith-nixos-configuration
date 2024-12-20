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

  lockBin = pkgs.writeScriptBin "lock-cmd" ''
    if [ "$1" = "--lid" ]; then
      hyprctl dispatch dpms on
      brightnessctl -r
    fi
    pidof hyprlock || ${getExe cfg.package}
  '';

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
      on-resume = "hyprctl dispatch dpms on";
    })
  ];

  areListenersInOrder = compareLists (a: b: a.on-timeout == b.on-timeout) (sort (a: b: a.timeout <= b.timeout) listener) listener;
in {
  options.hellebore.desktop-environment.lockscreen = {
    enable = mkEnableOption "Hellebore Swaylock and Swayidle configuration";

    font = extra-types.font {
      inherit (config.hellebore.font) size;
      name = "Fira Code";
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
      default = 0;
      description = "The grace period during which you can unlock without a
      password, in seconds.";
    };

    backgroundImage = mkOption {
      type = with types;
        oneOf [
          path
          (enum ["screenshot" ""])
        ];
      default = "screenshot";
      description = ''The image used as the background for Hyprlock. If `screenshot` is selected, it will take a screenshot before locking the screen.'';
    };

    package = mkPackageOption pkgs "hyprlock" {};

    bin = mkOption {
      readOnly = true;
      type = types.nonEmptyStr;
      default = getExe lockBin;
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
        message = "Hyprland must be enabled for Hyprlock and Hypridle to properly work.";
      }
      {
        assertion = os-config.hellebore.hyprland.enableHyprlockPam;
        message = "PAM service for Swaylock must be enabled to allow Hyprlock to properly log you in.";
      }
      {
        assertion = areListenersInOrder;
        message = ''
          Your timers should be in ascending order, such as
          `${concatStringsSep " <= " (mapAttrsToList (name: value: "${name}.timer") cfg.timeouts)}`
        '';
      }
    ];

    home.packages = theme.hyprlock.extraPackages;

    programs.hyprlock = {
      inherit (cfg) package;
      enable = true;
      settings =
        {
          general = {
            grace = cfg.gracePeriod;
          };
        }
        // (theme.hyprlock.settings {
          inherit (cfg) font backgroundImage;
        });
    };

    services.hypridle = {
      enable = true;
      settings = {
        inherit listener;
        general = {
          lock_cmd = cfg.bin;
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };
      };
    };
  };
}
