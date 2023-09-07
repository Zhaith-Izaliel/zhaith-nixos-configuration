{ config, lib, theme, ... }:

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
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      layout = cfg.keyboardLayout;
      xkbVariant = cfg.keyboardVariant;
      displayManager.sddm = {
        enable = true;
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
            Background = ../../assets/images/sddm/greeter.png;
          };
        };
      };
    };
  };
}

