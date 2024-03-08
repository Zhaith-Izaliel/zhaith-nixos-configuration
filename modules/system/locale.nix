{
  config,
  extra-types,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption types mkOption mkIf;
  cfg = config.hellebore.locale;
in {
  options.hellebore.locale = {
    enable = mkEnableOption "Hellebore locales configuration";

    consoleKeymap = mkOption {
      type = types.str;
      default = "fr-latin1";
      description = "Define the console keymap.";
    };

    keyboard = extra-types.keyboard {
      layout = "fr";
      variant = "oss_latin9";
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
      XKB_DEFAULT_LAYOUT = cfg.keyboard.layout;
      XKB_DEFAULT_VARIANT = cfg.keyboard.variant;
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
