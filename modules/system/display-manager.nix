{ config, lib, pkgs, theme, ... }:

with lib;

let
  cfg = config.hellebore.display-manager;
in
{
  options.hellebore.display-manager = {
    enable = mkEnableOption "Hellebore's Display Manager";

    screenWidth = mkOption {
      type = types.int;
      default = 1920;
      description = "Width of the screen.";
    };

    fontSize = mkOption {
      type = types.int;
      default = config.hellebore.fontSize;
      description = "Set SDDM font size";
    };

    screenHeight = mkOption {
      type = types.int;
      default = 1080;
      description = "Height of the screen.";
    };

    keyboardLayout = mkOption {
      type = types.str;
      default = "fr";
      description = "Keyboard layout used in the Display Manager.";
    };

    keyboardVariant = mkOption {
      type = types.str;
      default = "oss_latin9";
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

