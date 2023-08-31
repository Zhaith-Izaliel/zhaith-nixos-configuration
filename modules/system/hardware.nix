{ config, lib, pkgs, ... }:

with lib;

let
  usbBusDevices = "/sys/bus/usb/devices";
  cameraBus = "3-13"; # NOTE: switch it to the corresponding bus.
  cfg = config.hellebore.hardware;
in
{
  options.hellebore.hardware = {
    enable = mkEnableOption "Hellebore hardware configuration";

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
        type = types.str;
        default = "";
        description = "The Bus of the integrated camera to disable. Found in
        ${usbBusDevices}";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.integratedCamera.enable -> ((builtins.stringLength
        cfg.integratedCamera.cameraBus) != 0);
        message = "The camera bus can't be empty when trying to disable it.";
      }
    ];

    services = {
      printing = {
        enable = cfg.printing.enable;
        drivers = cfg.printing.drivers;
      };

      avahi = mkIf cfg.printing.enable {
        enable = true;

        nssmdns = true;

        openFirewall = true;
      };

      hardware.sane.enable = cfg.numerization.enable;

      systemd.services.disable-integrated-camera = mkIf cfg.integratedCamera.disable {
        enable = true;
        script = ''
        echo 0 > "${usbBusDevices}/${cfg.integratedCamera.cameraBus}/bConfigurationValue"
        '';
        wantedBy = [ "multi-user.target" ];
      };
    };
  } // (mkIf cfg.printing.oldPrinter {
    system.nssModules = with pkgs.lib; optional (!config.services.avahi.nssmdns) pkgs.nssmdns;
    system.nssDatabases.hosts = with pkgs.lib; optionals (!config.services.avahi.nssmdns) (mkMerge [
      (mkOrder 900 [ "mdns4_minimal [NOTFOUND=return]" ]) # must be before resolve
      (mkOrder 1501 [ "mdns4" ]) # 1501 to ensure it's after dns
    ]);
  }) // (mkIf cfg.bluetooth.enable {
    services.blueman.enable = true;
    hardware.bluetooth = {
      enable = true;
      package = pkgs.bluez.override { withExperimental = cfg.bluetooth.enablePowerSupport; };
    };
  });


}

