# Nvidia with prime offloading configuration
{ config, pkgs, ... }:

{
  services.xserver = {
    videoDrivers = [ "modesetting" ];
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;

    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      mesa
    ];
  };
}
