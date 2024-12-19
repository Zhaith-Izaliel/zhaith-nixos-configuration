{
  config,
  os-config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkPackageOption;
  cfg = config.hellebore.multimedia.davinci-resolve;
in {
  options.hellebore.multimedia.davinci-resolve = {
    enable = mkEnableOption "Davinci Resolve";

    package = mkPackageOption pkgs "davinci-resolve" {};
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = os-config.hellebore.hardware.amd.enable -> os-config.hellebore.hardware.amd.openCL.enable;
        message = "You need OpenCL enabled for Davinci Resolve to work on AMD. Enable it with `hellebore.hardware.amd.openCL.enable` in your system configuration.";
      }
    ];

    home.packages = [cfg.package];
  };
}
