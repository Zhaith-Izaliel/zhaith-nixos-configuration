{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.power-management;
  shutdownDate = "+10";
  cronTemplate = "50 2 * * *";
in
{
  options.hellebore.power-management = {
    enable = mkEnableOption "Hellebore power management script";

    cronTemplate = mkOption {
      type = types.nonEmptyStr;
      default = "";
      description = "Cron template used to define the time at which point the
      shutdown occurs.";
    };

    shutdownDate = mkOption {
      type = types.nonEmptyStr;
      default = "";
      description = "Set the GNU shutdown datetime.";
    };
  };

  config = mkIf cfg.enable {
    services.cron = {
      enable = true;
      systemCronJobs = [
        "${cfg.cronTemplate} root ${getExe pkgs.power-management} ${cfg.shutdownDate}"
      ];
    };
  };
}

