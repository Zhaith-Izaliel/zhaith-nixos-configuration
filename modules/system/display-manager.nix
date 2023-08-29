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

    screenHeight = mkOption {
      type = types.int;
      default = 1080;
      description = "Height of the screen.";
    };
  };

  config = mkIf cfg.enable {
    sddm = {
      settings = {
        Theme = {
          CursorTheme = theme.gtk.cursorTheme.name;
          CursorSize = 24;
          Font = theme.gtk.font.name;
        };
      };
    };

    sugarCandyNix = {
      settings = {
        ScreenWidth = cfg.screenWidth;
        ScreenHeight = cfg.screenHeight;
        FormPosition = "left";
        HaveFormBackground = true;
        PartialBlur = true;
        AccentColor = theme.colors.mauve;
        BackgroundColor = theme.colors.base;
        Font = theme.gtk.font.name;
        FontSize = toString theme.gtk.font.size;
        MainColor = theme.colors.text;
        ForceHideCompletePassword = true;
        Background = lib.cleanSource ../../../assets/images/sddm/greeter.png;
      };
    };
  };
}

