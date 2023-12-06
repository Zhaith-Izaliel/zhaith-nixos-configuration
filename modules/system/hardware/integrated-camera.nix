{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.hardware.integratedCamera;
  usbBusDevices = "/sys/bus/usb/devices";
in
{
  options.hellebore.hardware.integratedCamera = {
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

  config = mkIf cfg.disable {
    systemd.services.disable-integrated-camera = {
      enable = true;
      script = ''
      echo 0 > "${usbBusDevices}/${cfg.cameraBus}/bConfigurationValue"
      '';
      wantedBy = [ "multi-user.target" ];
    };
  };
}

