{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf optional;
  cfg = config.hellebore.hardware.gaming;
in {
  options.hellebore.hardware.gaming = {
    enable = mkEnableOption "Hellebore's gaming hardware support through Piper.";
    steam.enable = mkEnableOption "Steam hardware support.";
    logitech = {
      lcd.enable = mkEnableOption "Logitech LCD hardware support";
      wireless.enable = mkEnableOption "Logitech wireless hardware support";
    };
  };

  config = mkIf cfg.enable {
    services.ratbagd.enable = true; # NOTE: Needed for Piper

    environment.systemPackages = with pkgs;
      [
        piper
      ]
      ++ optional cfg.steam.enable sc-controller;

    hardware = {
      steam-hardware.enable = cfg.steam.enable;

      logitech = {
        wireless = mkIf cfg.logitech.wireless.enable {
          enable = true;
          enableGraphical = true;
        };

        lcd = mkIf cfg.logitech.lcd.enable {
          enable = true;
          startWhenNeeded = true;
        };
      };
    };
  };
}
