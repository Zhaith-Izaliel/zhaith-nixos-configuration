{ osConfig, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.desktop-environment.bluetooth;
in
{
  options.hellebore.desktop-environment.bluetooth = {
    enable = mkEnableOption "Hellebore's Bluetooth support";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> osConfig.hardware.bluetooth.enable;
        message = "Bluetooth needs to be enabled in your system configuration
        for Hellebore's bluetooth support to work.";
      }
    ];

    home.packages = with pkgs; [
      blueberry
    ];
  };
}

