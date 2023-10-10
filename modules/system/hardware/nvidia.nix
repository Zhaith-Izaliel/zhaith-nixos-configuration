{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.hardware.nvidia;
  nvidia-offload = pkgs.writeScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in
{
  options.hellebore.hardware.nvidia = {
      enable = mkEnableOption "Nvidia Support";
      prime = {
        enable = mkEnableOption "Nvidia PRIME support (laptop only)";
        intelBusId = mkOption {
          type = types.nonEmptyStr;
          default = "";
          description = "The intel GPU bus ID.";
        };

        intelDeviceId = mkOption {
          type = types.nonEmptyStr;
          default = "";
          description = "Set the intel GPU device ID to force load i915 on boot.";
        };

        nvidiaBusId =mkOption {
          type = types.nonEmptyStr;
          default = "";
          description = "The Nvidia GPU bus ID.";
        };

        offload.enable = mkEnableOption "Nvidia PRIME offload mode";

        sync.enable = mkEnableOption "Nvidia PRIME sync mode";
      };
    };

    config = mkMerge [
      ( mkIf cfg.enable {
        assertions = [
          {
            assertion = cfg.enable -> config.hardware.opengl.enable &&
            config.hardware.opengl.driSupport &&
            config.hardware.opengl.driSupport32Bit;
            message = "You must enable OpenGL with DRI support (64 bits and 32 bits)
            to support Nvidia.";
          }
          {
            assertion = cfg.prime.offload.enable -> !cfg.prime.sync.enable;
            message = "You can't enable both offload and sync at the same time.";
          }
          {
            assertion = cfg.prime.sync.enable -> !cfg.prime.offload.enable;
            message = "You can't enable both offload and sync at the same time.";
          }
        ];

        environment.systemPackages = with pkgs; [
          mesa-demos
        ] ++ lists.optional cfg.prime.enable nvidia-offload;

        services.xserver.videoDrivers = [ "nvidia" ];

        hardware.nvidia = {
          modesetting.enable = true;

          powerManagement = {
            enable = true;
            finegrained = true;
          };

          open = true;

          nvidiaSettings = true;

          nvidiaPersistenced = true;

          prime = mkIf cfg.prime.enable {
            inherit (cfg.prime) intelBusId nvidiaBusId;

            offload = mkIf cfg.prime.offload.enable {
              enable = true;
              enableOffloadCmd = true;
            };

            sync = mkIf cfg.prime.sync.enable {
              enable = true;
            };
          };
        };
      })
      ( mkIf (cfg.enable && cfg.prime.enable && (cfg.prime.intelBusId != "")) {
        boot.initrd.kernelModules = [ "i915" ];
        # boot.kernelParams = [ "i915.force_probe=${cfg.prime.intelDeviceId}" ];
      })
    ];
    }

