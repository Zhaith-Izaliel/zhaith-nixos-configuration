{ config, pkgs, ... }:

{
  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";

    supportedLocales = [
      "ja_JP.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "fr_FR.UTF-8/UTF-8"
    ];

    # Ibus me thod
    inputMethod = {
      enabled = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ anthy ];
    };
  };

  console = {
     font = "Lat2-Terminus32";
     keyMap = "fr-latin1";
  };

  environment.systemPackages = with pkgs; [
    hunspell
    hunspellDicts.en_US
    hunspellDicts.fr-moderne
    hunspellDicts.fr-classique
    hunspellDicts.fr-reforme1990
  ];
}