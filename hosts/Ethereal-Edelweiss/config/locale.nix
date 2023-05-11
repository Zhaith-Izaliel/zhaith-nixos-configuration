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
  };

  console = {
     font = "Lat2-Terminus32";
     keyMap = "fr-latin1";
  };
}