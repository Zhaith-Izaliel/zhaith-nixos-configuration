# Boot loader config
{ config, pkgs, ... }:

{
  boot = {
    kernelParams = [
      "acpi_rev_override"
      "mem_sleep_default=deep"
      "nvidia-drm.modeset=1"
    ];
  };
}