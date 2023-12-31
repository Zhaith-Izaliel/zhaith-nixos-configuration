{ config, lib, pkgs, ... }:

with lib;

let
   cfg = config.hellebore.locale;
in
{
  options.hellebore.locale = {
    enable = mkEnableOption "Hellebore locales configuration";

    consoleKeymap = mkOption {
      type = types.str;
      default = "fr-latin1";
      description = "Define the console keymap.";
    };

    keyboard = {
      defaultLayout = mkOption {
        type = types.str;
        default = "fr";
        description = "The default keyboard layout for XKB.";
      };

      defaultVariant = mkOption {
        type = types.str;
        default = "oss_latin9";
        description = "The default keyboard variant for XKB.";
      };
    };
  };

  config = mkIf cfg.enable {
    i18n = {
      defaultLocale = "en_US.UTF-8";

      supportedLocales = [
        "ja_JP.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
        "fr_FR.UTF-8/UTF-8"
      ];
    };

    environment.variables = {
      XKB_DEFAULT_LAYOUT = cfg.keyboard.defaultLayout;
      XKB_DEFAULT_VARIANT = cfg.keyboard.defaultVariant;
    };

    console = {
      keyMap = cfg.consoleKeymap;
    };

    environment.systemPackages = with pkgs; [
      hunspell
      hunspellDicts.en_US
      hunspellDicts.fr-moderne
      hunspellDicts.fr-classique
      hunspellDicts.fr-reforme1990
    ];
  };
}

