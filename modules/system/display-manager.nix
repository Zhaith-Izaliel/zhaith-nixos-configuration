{ config, lib, theme, extra-types, ... }:

with lib;

let
  cfg = config.hellebore.display-manager;
  defaultMonitor = builtins.elemAt config.hellebore.monitors 0;
in
{
  options.hellebore.display-manager = {
    enable = mkEnableOption "Hellebore's Display Manager";

    screenWidth = mkOption {
      type = types.int;
      default = defaultMonitor.width;
      description = "Width of the screen.";
    };

    fontSize = extra-types.fontSize {
      default = config.hellebore.font.size;
      description = "Set SDDM font size";
    };

    screenHeight = mkOption {
      type = types.int;
      default = defaultMonitor.height;
      description = "Height of the screen.";
    };

    keyboardLayout = mkOption {
      type = types.str;
      default = config.hellebore.locale.keyboard.defaultLayout;
      description = "Keyboard layout used in the Display Manager.";
    };

    keyboardVariant = mkOption {
      type = types.str;
      default = config.hellebore.locale.keyboard.defaultVariant;
      description = "Keyboard variant used in the Display Manager.";
    };

    background = {
      path  = mkOption {
        type = types.oneOf [ types.path types.str ];
        default = "";
        description = "The path to the background image to use in the greeter.";
      };
      fit = mkOption {
        type = types.enum [ "Fill" "Contain" "Cover" "ScaleDown" ];
        default = "Contain";
        description = "How the background image covers the screen if the aspect
        ratio doesn't match";
      };
    };
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      layout = cfg.keyboardLayout;
      xkbVariant = cfg.keyboardVariant;
      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        settings = {
          Theme = {
            CursorTheme = theme.gtk.cursorTheme.name;
            CursorSize = 24;
            Font = cfg.fontSize;
          };
        };

        sugarCandyNix = {
          enable = true;
          settings = {
            ScreenWidth = cfg.screenWidth;
            ScreenHeight = cfg.screenHeight;
            FormPosition = "left";
            HaveFormBackground = true;
            PartialBlur = true;
            AccentColor = theme.colors.mauve;
            BackgroundColor = theme.colors.base;
            Font = theme.gtk.font.name;
            FontSize = toString cfg.fontSize;
            MainColor = theme.colors.text;
            ForceHideCompletePassword = true;
            Background = cfg.background.path;
          };
        };
      };
    };
  };
}

