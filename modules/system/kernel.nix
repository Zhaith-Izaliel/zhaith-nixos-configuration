{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.hellebore.kernel;
in {
  options.hellebore.kernel = {
    enable = mkEnableOption "Hellebore's Kernel configuration";
  };

  config = mkIf cfg.enable {
    boot.initrd.kernelModules = ["i915"];
    boot.kernelPackages = pkgs.linuxPackages_zen;
  };
}
