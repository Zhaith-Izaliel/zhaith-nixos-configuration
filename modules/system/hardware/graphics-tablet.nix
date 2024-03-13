{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types mkEnableOption mkIf mkMerge mkOption optionals;

  cfg = config.hellebore.hardware.graphics-tablet;
in {
  options.hellebore.hardware.graphics-tablet = {
    enable = mkEnableOption "Hellebore's graphics tablet support";

    isWacom = mkOption {
      type = types.bool;
      description = "Install the Wacom kernel module in place of OpenTablet.";
      default = false;
    };
  };

  config = mkMerge (optionals cfg.enable [
    (mkIf (!cfg.isWacom) {
      hardware.opentabletdriver = {
        enable = true;
        daemon.enable = true;
      };
    })

    (mkIf (cfg.isWacom) {
      boot.kernelModules = ["wacom"];
      environment.systemPackages = with pkgs; [wacomtablet];
      services.xserver.wacom.enable = true;
    })
  ]);
}
