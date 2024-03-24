{
  config,
  lib,
  extra-types,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  theme = config.hellebore.theme.themes.${cfg.theme};
  cfg = config.hellebore.display-manager;
  defaultMonitor = builtins.elemAt config.hellebore.monitors 0;
in {
  options.hellebore.display-manager = {
    enable = mkEnableOption "Hellebore's Display Manager";

    screenWidth = mkOption {
      type = types.int;
      default = defaultMonitor.width;
      description = "Width of the screen.";
    };

    font = extra-types.font {
      inherit (config.hellebore.font) size name;
      sizeDescription = "Set the display manager font size.";
      nameDescription = "Set the display manager font family.";
    };

    screenHeight = mkOption {
      type = types.int;
      default = defaultMonitor.height;
      description = "Height of the screen.";
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
    services.xserver = {
      enable = true;
      xkb = {
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
              ScreenWidth = cfg.screenWidth;
              ScreenHeight = cfg.screenHeight;
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
