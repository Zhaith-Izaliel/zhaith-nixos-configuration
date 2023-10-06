{ config, lib, pkgs, ... }:

with lib;

let
  usbBusDevices = "/sys/bus/usb/devices";
  cfg = config.hellebore.hardware;
  nvidia-offload = pkgs.writeScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in
{
  options.hellebore.hardware = {
    ntfs.enable = mkEnableOption "NTFS support";

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

    nvidia = {
      enable = mkEnableOption "Nvidia Support";
      prime = {
        enable = mkEnableOption "Nvidia PRIME offload support (laptop only)";
        intelBusId = mkOption {
          type = types.nonEmptyStr;
          default = "";
          description = "The intel GPU bus ID.";
        };

        nvidiaBusId =mkOption {
          type = types.nonEmptyStr;
          default = "";
          description = "The Nvidia GPU bus ID.";
        };
      };
    };

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
    assertions = [
      {
        assertion = cfg.nvidia.enable -> config.hardware.opengl.enable &&
        config.hardware.opengl.driSupport &&
        config.hardware.opengl.driSupport32Bit;
        message = "You must enable OpenGL with DRI support (64 bits and 32 bits)
        to support Nvidia";
      }
    ];

    environment.systemPackages = lists.optional cfg.ntfs.enable pkgs.ntfs3g ++
    lists.optional cfg.nvidia.prime.enable nvidia-offload;
    boot.supportedFilesystems = lists.optional cfg.ntfs.enable "ntfs";

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

    services.xserver.videoDrivers = lists.optional cfg.nvidia.enable "nvidia";

    hardware.nvidia = mkIf cfg.nvidia.enable {
      modesetting.enable = true;

      powerManagement = {
        enable = false;
        finegrained = false;
      };

      open = true;

      nvidiaSettings = true;

      prime = mkIf cfg.nvidia.prime.enable {
        inherit (cfg.nvidia.prime) intelBusId nvidiaBusId;
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };
    };
  };
}

