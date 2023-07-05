{ config, pkgs, ... }:

let
  usbBusDevices = "/sys/bus/usb/devices";
  cameraBus = "3-13"; # NOTE: switch it to the corresponding bus.
in
{
  services = {
    printing = {
      # Enable CUPS to print documents.
      enable = true;
      drivers = with pkgs; [ epson-escpr ];
    };

    avahi = {
      enable = true;

      # Important to resolve .local domains of printers, otherwise you get an error
      # like  "Impossible to connect to XXX.local: Name or service not known"
      nssmdns = false;
    };
  };

  system.nssModules = with pkgs.lib; optional (!config.services.avahi.nssmdns) pkgs.nssmdns;
  system.nssDatabases.hosts = with pkgs.lib; optionals (!config.services.avahi.nssmdns) (mkMerge [
    (mkOrder 900 [ "mdns4_minimal [NOTFOUND=return]" ]) # must be before resolve
    (mkOrder 1501 [ "mdns4" ]) # 1501 to ensure it's after dns
  ]);

  hardware.sane = {
    enable = true;
  };

  systemd.services.disable-integrated-camera = {
    enable = true;
    script = ''
      echo 0 > "${usbBusDevices}/${cameraBus}/bConfigurationValue"
    '';
    wantedBy = [ "multi-user.target" ];
  };
}

