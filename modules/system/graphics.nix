{
  config,
  options,
  extra-utils,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf types;
  inherit (extra-utils.compatibility) mkCompatibilityAttrs;
  cfg = config.hellebore.graphics;
in {
  options.hellebore.graphics = {
    enable = mkEnableOption "Hellebore OpenGL configuration";

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "A list of extra packages to add to `hardware.graphics.extraPackages`.";
    };
  };

  config = mkIf cfg.enable (
    # RETROCOMPATIBLITY: Should be removed when NixOS Stable moves to 24.11
    mkCompatibilityAttrs {
      name = "graphics";
      set = options.hardware;

      new = {
        hardware.graphics = {
          enable = true;
          enable32Bit = true;
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

      old = {
        hardware.opengl = {
          enable = true;
          driSupport32Bit = true;
          driSupport = true;

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
  );
}
