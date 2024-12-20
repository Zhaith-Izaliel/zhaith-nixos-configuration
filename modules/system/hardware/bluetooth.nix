{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkPackageOption;
  cfg = config.hellebore.hardware.bluetooth;
in {
  options.hellebore.hardware.bluetooth = {
    enable = mkEnableOption "Bluetooth support";

    package = mkPackageOption pkgs "bluez" {};

    enableExperimentalFeatures = mkEnableOption "Bluez Experimental Features";
  };

  config = mkIf cfg.enable {
    hardware.bluetooth = {
      inherit (cfg) package;
      enable = true;
      powerOnBoot = true;

      settings = {
        General = {
          Experimental = cfg.enableExperimentalFeatures;
        };
      };
    };
  };
}
