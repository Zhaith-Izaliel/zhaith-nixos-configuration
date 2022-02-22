# Boot loader config
{ config, pkgs, ... }:

{
  boot = {
    kernelParams = [
      "acpi_rev_override"
      "mem_sleep_default=deep"
      "nvidia-drm.modeset=1"
    ];
    extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
    initrd = {
      kernelModules = [ "nvidia_x11" ];
    };
  };
}