{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hellebore.hardware.bluetooth;
in {
  options.hellebore.hardware.bluetooth = {
    enable = mkEnableOption "Bluetooth support";
    enablePowerSupport = mkEnableOption "Bluetooth power visualization support";
  };

  config = mkIf cfg.enable {
    services.blueman.enable = true;

    hardware.bluetooth = {
      enable = true;
      package = pkgs.bluez.override {withExperimental = cfg.enablePowerSupport;};
    };
  };
}
