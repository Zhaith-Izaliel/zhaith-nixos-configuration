{
  config,
  lib,
  extra-types,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  theme = config.hellebore.theme.themes.${cfg.theme};
  cfg = config.hellebore.display-manager;
in {
  options.hellebore.display-manager = {
    enable = mkEnableOption "Hellebore's Display Manager";

    monitor = mkOption {
      default = builtins.elemAt config.hellebore.monitors 0;
      type = extra-types.monitor;
      description = "The monitor information on which the display manager is rendered.";
    };

    font = extra-types.font {
      inherit (config.hellebore.font) size name;
      sizeDescription = "Set the display manager font size.";
      nameDescription = "Set the display manager font family.";
    };

    keyboard = {
      layout = mkOption {
        type = types.str;
        default = config.hellebore.locale.keyboard.layout;
        description = "Keyboard layout used in the Display Manager.";
      };

      variant = mkOption {
        type = types.str;
        default = config.hellebore.locale.keyboard.variant;
        description = "Keyboard variant used in the Display Manager.";
      };
    };

    theme = extra-types.theme.name {
      default = config.hellebore.theme.name;
      description = "Defines the display manager theme.";
    };

    background = {
      path = mkOption {
        type = types.oneOf [types.path types.str];
        default = "";
        description = "The path to the background image to use in the greeter.";
      };
      fit = mkOption {
        type = types.enum ["Fill" "Contain" "Cover" "ScaleDown"];
        default = "Contain";
        description = "How the background image covers the screen if the aspect
        ratio doesn't match";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.length config.hellebore.monitors > 0;
        message = "You need at least one monitor in `config.hellebore.monitors` to render your display manager.";
      }
      {
        assertion = config.hellebore.graphics.enable;
        message = "Hardware acceleration is needed to render your display manager. Enable it with `config.hellebore.graphics.enable`.";
      }
    ];

    services = {
      xserver.xkb = {
        inherit (cfg.keyboard) layout variant;
      };

      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        settings = {
          Theme = {
            CursorTheme = theme.gtk.cursorTheme.name;
            CursorSize = 24;
            Font = cfg.font.size;
          };
        };

        sugarCandyNix = {
          enable = true;
          settings =
            {
              ScreenWidth = cfg.monitor.width;
              ScreenHeight = cfg.monitor.height;
              Font = cfg.font.name;
              FontSize = toString cfg.font.size;
              Background = cfg.background.path;
            }
            // theme.sddm.settings;
        };
      };
    };
  };
}
