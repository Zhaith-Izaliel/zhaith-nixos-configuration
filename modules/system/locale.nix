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
  };

  config = mkIf cfg.enable {
    i18n = {
      defaultLocale = "en_US.UTF-8";

      supportedLocales = [
        "ja_JP.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
        "fr_FR.UTF-8/UTF-8"
      ];

      inputMethod = {
        enabled = "ibus";
        ibus.engines = with pkgs.ibus-engines; [ anthy ];
      };
    };

    console = {
      font = "Lat2-Terminus32";
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

