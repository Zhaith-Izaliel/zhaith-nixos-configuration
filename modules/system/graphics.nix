{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf types;
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

  config = mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = cfg.extraPackages;
    };
  };
}
