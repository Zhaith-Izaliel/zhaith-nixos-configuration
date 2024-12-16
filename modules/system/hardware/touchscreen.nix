{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkPackageOption;
  cfg = config.hellebore.hardware.touchscreen;
in {
  options.hellebore.hardware.touchscreen = {
    enable = mkEnableOption "Hellebore's touchscreens support through Touchegg";

    package = mkPackageOption pkgs "touchegg" {};
  };

  config = mkIf cfg.enable {
    services.touchegg = {
      inherit (cfg) package;
      enable = true;
    };
  };
}
