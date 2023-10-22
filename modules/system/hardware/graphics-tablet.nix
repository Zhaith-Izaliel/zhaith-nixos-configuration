{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.hardware.graphics-tablet;
in
{
  options.hellebore.hardware.graphics-tablet = {
    enable = mkEnableOption "Hellebore's graphics tablet support";

    isWacom = mkOption {
      type = types.bool;
      description = "Install the Wacom kernel module in place of OpenTablet.";
      default = false;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      hardware.opentabletdriver.enable = !cfg.isWacom;
    })

    (mkIf cfg.enable && cfg.isWacom {
      boot.kernelModules = [ "wacom" ];
      environment.systemPackage = with pkgs; [ wacomtablet ];
    })
  ];
}

