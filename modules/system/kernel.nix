{ config, lib, ... }:

with lib;

let
  cfg = config.hellebore.kernel;
in
{
  options.hellebore.kernel = {
    enable = mkEnableOption "Hellebore Kernel configuration";
  };

  config = mkIf cfg.enable {
    # boot.initrd.kernelModules = [ "i915" ];
  };
}

