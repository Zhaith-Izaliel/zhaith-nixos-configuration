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
      oldPrinter = mkEnableOption "Printing support for an old printer";
      drivers = mkOption {
        type = types.listOf type.package;
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

  config = mkMerge [
    (mkIf cfg.printing.enable {
      services = {
        printing = {
          enable = true;
          drivers = true;
        };

        avahi = {
          enable = true;

          nssmdns = true;

          openFirewall = true;
        };
      };
    })

    (mkIf cfg.numerization.enable {
      hardware.sane.enable = true;
    })

    (mkIf cfg.integratedCamera.disable {
      services.systemd.services.disable-integrated-camera = {
        enable = true;
        script = ''
        echo 0 > "${usbBusDevices}/${cfg.integratedCamera.cameraBus}/bConfigurationValue"
        '';
        wantedBy = [ "multi-user.target" ];
      };
    })

    (mkIf cfg.printing.oldPrinter {
      system.nssModules = with pkgs.lib; optional (!config.services.avahi.nssmdns) pkgs.nssmdns;
      system.nssDatabases.hosts = with pkgs.lib; optionals (!config.services.avahi.nssmdns) (mkMerge [
        (mkOrder 900 [ "mdns4_minimal [NOTFOUND=return]" ]) # must be before resolve
        (mkOrder 1501 [ "mdns4" ]) # 1501 to ensure it's after dns
      ]);
    })

    (mkIf cfg.bluetooth.enable {
      services.blueman.enable = true;
      hardware.bluetooth = {
        enable = true;
        package = pkgs.bluez.override { withExperimental = cfg.bluetooth.enablePowerSupport; };
      };
    })
  ];
}

