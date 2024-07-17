{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf optionalString;
  cfg = config.hellebore.hardware.nvidia;
in {
  options.hellebore.hardware.nvidia = {
    enable = mkEnableOption "Nvidia Support";

    package = mkOption {
      type = types.package;
      default = config.boot.kernelPackages.nvidiaPackages.production;
      description = "Defines the default Nvidia driver package to use.";
    };

    power-profiles.enable = mkEnableOption "power-profiles-daemon support";

    power-management.enable = mkEnableOption "Nvidia power management
      capabilities";

    persistenced.enable = mkEnableOption "Nvidia Persistence Daemon";

    modesetting.enable = mkEnableOption "Nvidia Kernel Modesetting";

    open = mkEnableOption "Nvidia Open-Source Driver";

    deviceFilterName = mkOption {
      type = types.nonEmptyStr;
      default = "";
      description = "Defines the device filter name for DXVK for Nvidia.";
    };

    prime = {
      intelBusId = mkOption {
        type = types.nonEmptyStr;
        default = "";
        description = "The intel GPU bus ID.";
      };

      nvidiaBusId = mkOption {
        type = types.nonEmptyStr;
        default = "";
        description = "The Nvidia GPU bus ID.";
      };

      offload.enable = mkEnableOption "Nvidia PRIME offload mode";

      sync.enable = mkEnableOption "Nvidia PRIME sync mode";

      reverseSync.enable = mkEnableOption "Nvidia PRIME reverse-sync mode";
    };

    fixes = {
      usbCDriversWronglyLoaded = (mkEnableOption null) // {description = "Fixes the USB-C driver for the NVidia Card being loaded while not having USB-C capabilities, creating a Kernel Panic on Shutdowns";};
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.hardware.opengl.enable && config.hardware.opengl.driSupport32Bit && config.hardware.opengl.driSupport;
        message = "You must enable OpenGL to support Nvidia.";
      }
      {
        assertion = config.hellebore.vm.enable -> cfg.forceWaylandOnMesa;
        message = "Forcing wayland on Mesa is a required step if you're using a VM with GPU passthrough.";
      }
      {
        assertion = cfg.prime.sync.enable -> !(cfg.forceWaylandOnMesa);
        message = "You shouldn't force Wayland on Mesa when using PRIME Sync with Nvidia.";
      }
    ];

    services.power-profiles-daemon.enable = cfg.power-profiles.enable;

    environment.systemPackages = with pkgs; [
      mesa-demos
    ];

    services.xserver.videoDrivers = ["nvidia"]; # IMPORTANT: this activates the hardware.nvidia module

    hardware.nvidia = {
      inherit (cfg) modesetting open package;

      powerManagement = mkIf cfg.power-management.enable {
        enable = true;
        finegrained = true;
      };

      nvidiaSettings = true;

      nvidiaPersistenced = cfg.persistenced.enable;

      prime = {
        inherit (cfg.prime) intelBusId nvidiaBusId;

        offload = mkIf (cfg.prime.offload.enable || cfg.prime.reverseSync.enable) {
          enable = true;
          enableOffloadCmd = true;
        };

        reverseSync = mkIf cfg.prime.reverseSync.enable {
          enable = true;
        };

        sync = mkIf cfg.prime.sync.enable {
          enable = true;
        };
      };
    };

    # NOTE: Fix Kernel Panics with the Kernel trying to use the USB-C driver on a non-USB-C compatible Nvidia Card.
    boot.extraModprobeConfig = optionalString cfg.fixes.usbCDriversWronglyLoaded ''
      blacklist i2c_nvidia_gpu
    '';
  };
}
