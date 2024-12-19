{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkPackageOption optional;
  cfg = config.hellebore.hardware.amd;
in {
  options.hellebore.hardware.amd = {
    enable = mkEnableOption "AMD LACT support";

    package = mkPackageOption pkgs "lact" {};

    openCL = {
      enable = mkEnableOption "OpenCL support";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.hellebore.graphics.enable;
        message = "You must enable graphics support for AMD.";
      }
    ];

    environment.systemPackages = [cfg.package];
    systemd.packages = [cfg.package];
    systemd.services.lactd.wantedBy = ["multi-user.target"];

    hardware.amdgpu.opencl.enable = cfg.openCL.enable;
  };
}
