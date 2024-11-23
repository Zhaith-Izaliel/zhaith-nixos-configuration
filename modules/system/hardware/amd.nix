{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkPackageOption;
  cfg = config.hellebore.hardware.amd;
in {
  options.hellebore.hardware.amd = {
    enable = mkEnableOption "AMD LACT support";

    package = mkPackageOption pkgs "lact" {};
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [cfg.package];
    systemd.packages = [cfg.package];
    systemd.services.lactd.wantedBy = ["multi-user.target"];
  };
}
