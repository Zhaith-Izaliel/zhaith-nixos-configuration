{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.hardware.nvidia;
in
{
  options.hellebore.hardware.nvidia = {
      enable = mkEnableOption "Nvidia Support";

      power-profiles.enable = mkEnableOption "power-profiles-daemon support";

      power-management.enable = mkEnableOption "Nvidia power management
      capabilities";

      persistenced.enable = mkEnableOption "Nvidia Persistence Daemon";

      modesetting.enable = mkEnableOption "Nvidia Kernel Modesetting";

      open = mkEnableOption "Nvidia Open-Source Driver";

      forceWaylandOnMesa = (mkEnableOption null) // {
        description = "Force Wayland to run on Mesa instead of Nvidia in some
        rare cases. You can check that by using `nvidia-smi` and see if your
        compositor is running on Nvidia.";
      };

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

        nvidiaBusId =mkOption {
          type = types.nonEmptyStr;
          default = "";
          description = "The Nvidia GPU bus ID.";
        };

        offload.enable = mkEnableOption "Nvidia PRIME offload mode";

        sync.enable = mkEnableOption "Nvidia PRIME sync mode";

        reverseSync.enable = mkEnableOption "Nvidia PRIME reverse-sync mode";
      };
    };

    config = mkIf cfg.enable {
      assertions = [
        {
          assertion = cfg.enable -> config.hardware.opengl.enable &&
          config.hardware.opengl.driSupport &&
          config.hardware.opengl.driSupport32Bit;
          message = "You must enable OpenGL with DRI support (64 bits and 32 bits) to support Nvidia.";
        }
        {
          assertion = config.hellebore.vm.enable -> (cfg.enable && cfg.forceWaylandOnMesa);
          message = "Forcing wayland on Mesa is a required step if you're using a VM with GPU passthrough.";
        }
        {
          assertion = cfg.prime.sync.enable -> !(cfg.enable && cfg.forceWaylandOnMesa);
          message = "You shouldn't force Wayland on Mesa when using PRIME Sync with Nvidia.";
        }
      ];

      services.power-profiles-daemon.enable = cfg.power-profiles.enable;

      environment.systemPackages = with pkgs; [
        mesa-demos
      ];

      services.xserver.videoDrivers = [ "nvidia" ]; # IMPORTANT: this activates
                                                    # the hardware.nvidia module

      # NOTE: This forces Libglvnd to use Mesa instead of Nvidia.
      environment.variables = mkIf cfg.forceWaylandOnMesa {
        "__EGL_VENDOR_LIBRARY_FILENAMES" =
          "${pkgs.mesa.drivers}/share/glvnd/egl_vendor.d/50_mesa.json";
        "__GLX_VENDOR_LIBRARY_NAME" = "mesa";
      };

      hardware.nvidia = {
        inherit (cfg) modesetting open;

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
    };
  }

