{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf types;
  cfg = config.hellebore.opengl;
in {
  options.hellebore.opengl = {
    enable = mkEnableOption "Hellebore OpenGL configuration";

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "A list of extra packages to add to `hardware.opengl.extraPackages`.";
    };
  };

  config = mkIf cfg.enable {
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;

      extraPackages = with pkgs;
        [
          intel-media-driver
          vaapiIntel
          vaapiVdpau
          libvdpau-va-gl
          mesa
        ]
        ++ cfg.extraPackages;
    };
  };
}
