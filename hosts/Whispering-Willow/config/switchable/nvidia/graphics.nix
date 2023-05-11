{ config, pkgs, ... }:

{

  services.xserver = {
    videoDrivers = [ "nvidia" ];

    displayManager.sessionCommands = ''
    ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource modesetting NVIDIA-0
    ${pkgs.xorg.xrandr}/bin/xrandr --auto
    '';
  };

  hardware = {
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
      driSupport = true;
    };

    nvidia = {
      nvidiaPersistenced = true;
      modesetting.enable = true;
    };
  };
}
