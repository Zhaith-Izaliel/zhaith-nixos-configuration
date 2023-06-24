{ ... }:

let
  usbBusDevices = "/sys/bus/usb/devices";
  cameraBus = "3-13"; # NOTE: switch it to the corresponding bus.
in
{
  systemd.services.disable-integrated-camera = {
    script = ''
      echo 0 > "${usbBusDevices}/${cameraBus}/bConfigurationValue"
    '';
    wantedBy = [ "multi-user.target" ];
  };
}

