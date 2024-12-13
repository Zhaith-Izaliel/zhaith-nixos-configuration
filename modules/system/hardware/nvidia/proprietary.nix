{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  cfg = config.hellebore.hardware.nvidia.proprietary;
in {
  options.hellebore.hardware.nvidia.proprietary = {
    enable = mkEnableOption "Nvidia Support";

    package = mkOption {
      type = types.package;
      default = config.boot.kernelPackages.nvidiaPackages.production;
      description = "Defines the default Nvidia driver package to use.";
    };

    power-management.enable = mkEnableOption "Nvidia power management
      capabilities";

    persistenced.enable = mkEnableOption "Nvidia Persistence Daemon";

    modesetting.enable = mkEnableOption "Nvidia Kernel Modesetting";

    open = mkEnableOption "Nvidia Open-Source Driver";

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
        assertion = config.hellebore.graphics.enable;
        message = "You must enable graphics support for Nvidia.";
      }
      {
        assertion = cfg.enable -> !config.hellebore.hardware.nvidia.nouveau.enable;
        message = "Nouveau and the proprietary Nvidia drivers are mutually exclusive, you should enable only one of them.";
      }
    ];

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

    boot.extraModprobeConfig = ''
      blacklist nouveau
      options nouveau modeset=0
    '';
  };
}
