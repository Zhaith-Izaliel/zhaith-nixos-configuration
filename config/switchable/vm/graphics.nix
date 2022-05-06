# Nvidia with prime offloading configuration
{ config, pkgs, ... }:

{
  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;
    videoDrivers = [ "modesetting" ];

    # Enable UDev rules and driver for wacom tablet
    wacom.enable = true;

    # Configure keymap in X11
    layout = "fr";
    # xkbOptions = "eurosign:e";

    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;

    useGlamor = true;
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
