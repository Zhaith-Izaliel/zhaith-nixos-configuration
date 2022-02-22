# Nvidia with prime offloading configuration
{ config, pkgs, ... }:

# let
#    nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
#       export __NV_PRIME_RENDER_OFFLOAD=1
#       export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
#       export __GLX_VENDOR_LIBRARY_NAME=nvidia
#       export __VK_LAYER_NV_optimus=NVIDIA_only
#       exec -a "$0" "$@"
#    '';
# in
{
  #environment.systemPackages = [ nvidia-offload ];

  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;
    videoDrivers = [ "nvidia" ];

    # Configure keymap in X11
    layout = "fr";
    # xkbOptions = "eurosign:e";

    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;

    displayManager.sessionCommands = ''
    ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource modesetting NVIDIA-0
    ${pkgs.xorg.xrandr}/bin/xrandr --auto
    '';
  };

  hardware = {
    enable = true;
    driSupport = true;

    opengl.extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
    nvidia = {
      prime = {
        #offload.enable = true;
        sync.enable = true;

        # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
        intelBusId = "PCI:0:2:0";

        # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
        nvidiaBusId = "PCI:1:0:0";
      };

      nvidiaPersistenced = true;
      modesetting.enable = true;
    };
  };
}
