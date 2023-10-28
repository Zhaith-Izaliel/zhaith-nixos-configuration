{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.hardware.nvidia;
in
{
  options.hellebore.hardware.nvidia = {
      enable = mkEnableOption "Nvidia Support";

      power-profiles.enable = mkEnableOption "power-profiles-daemon support";

      modesetting.enable = mkEnableOption "Nvidia Kernel Modesetting";

      prime = {
        enable = mkEnableOption "Nvidia PRIME support (laptop only)";

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
          message = "You must enable OpenGL with DRI support (64 bits and 32 bits)
          to support Nvidia.";
        }
      ];

      services.power-profiles-daemon.enable = cfg.power-profiles.enable;

      environment.systemPackages = with pkgs; [
        mesa-demos
      ];

      services.xserver.videoDrivers = [ "nvidia" ]; # IMPORTANT: this activates
                                                    # the hardware.nvidia module

      hardware.nvidia = {
        inherit (cfg) modesetting;

        powerManagement = {
          enable = true;
          finegrained = true;
        };

        open = true;

        nvidiaSettings = true;

        nvidiaPersistenced = false;

        prime = mkIf cfg.prime.enable {
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

