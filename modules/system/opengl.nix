{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hellebore.opengl;
in {
  options.hellebore.opengl = {
    enable = mkEnableOption "Hellebore OpenGL configuration";
  };

  config = mkIf cfg.enable {
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;

      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        mesa
      ];
    };
  };
}
