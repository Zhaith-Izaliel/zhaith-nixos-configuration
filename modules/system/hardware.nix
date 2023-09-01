{ config, lib, pkgs, ... }:

with lib;

let
  usbBusDevices = "/sys/bus/usb/devices";
  cfg = config.hellebore.hardware;
in
{
  options.hellebore.hardware = {
    bluetooth = {
      enable = mkEnableOption "Bluetooth support";
      enablePowerSupport = mkEnableOption "Bluetooth power visualization support";
    };

    printing = {
      enable = mkEnableOption "Printing support";
      drivers = mkOption {
        type = types.listOf types.package;
        default = [];
        description = "Drivers packages in case your printer doesn't support the
        IPP everywhere protocol";
      };
    };

    numerization.enable = mkEnableOption "Numerization support";

    integratedCamera = {
      disable = mkOption {
        type = types.bool;
        default = false;
        description = "Disable the integrated camera at boot";
      };

      cameraBus = mkOption {
        type = types.nonEmptyStr;
        default = "";
        description = "The Bus of the integrated camera to disable. Found in
        ${usbBusDevices}";
      };
    };
  };

  config = {
    services = {
      printing = mkIf cfg.printing.enable {
        enable = true;
        drivers = cfg.printing.drivers;
      };

      avahi = mkIf cfg.printing.enable {
        enable = true;

        nssmdns = true;

        openFirewall = true;
      };

      blueman.enable = cfg.bluetooth.enable;
    };

    hardware.sane.enable = cfg.numerization.enable;

    systemd.services.disable-integrated-camera = mkIf cfg.integratedCamera.disable {
      enable = true;
      script = ''
      echo 0 > "${usbBusDevices}/${cfg.integratedCamera.cameraBus}/bConfigurationValue"
      '';
      wantedBy = [ "multi-user.target" ];
    };

    hardware.bluetooth = mkIf cfg.bluetooth.enable {
      enable = true;
      package = pkgs.bluez.override { withExperimental = cfg.bluetooth.enablePowerSupport; };
    };
  };
}

