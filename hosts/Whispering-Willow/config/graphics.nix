{ pkgs, ... }:

{
  services.xserver = {
    videoDrivers = [ "modesetting" ];
    displayManager.gdm.wayland = true;
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

