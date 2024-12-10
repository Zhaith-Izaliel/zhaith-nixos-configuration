{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkPackageOption;
  cfg = config.hellebore.power-profiles;
in {
  options.hellebore.power-profiles = {
    enable = mkEnableOption "Power-Profiles Manager";

    package = mkPackageOption pkgs "power-profiles-daemon" {};
  };

  config = mkIf cfg.enable {
    services.power-profiles-daemon = {
      inherit (cfg) package;
      enable = true;
    };
  };
}
