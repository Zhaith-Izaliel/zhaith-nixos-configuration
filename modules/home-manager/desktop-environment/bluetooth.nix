{
  os-config,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hellebore.desktop-environment.bluetooth;
in {
  options.hellebore.desktop-environment.bluetooth = {
    enable = mkEnableOption "Hellebore's Bluetooth support";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = os-config.hardware.bluetooth.enable;
        message = "Bluetooth needs to be enabled in your system configuration
        for Hellebore's bluetooth support to work.";
      }
    ];

    home.packages = with pkgs; [
      blueberry
    ];
  };
}
