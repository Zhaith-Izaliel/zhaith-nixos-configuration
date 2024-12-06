{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types mkPackageOption getExe;
  cfg = config.hellebore.desktop-environment.nightlights;
in {
  options.hellebore.desktop-environment.nightlights = {
    enable = mkEnableOption "Night lights";

    package = mkPackageOption pkgs "hyprland-nightlights" {};

    startTime = mkOption {
      default = "*-*-* 19:00:00";
      type = types.nonEmptyStr;
      description = "The time at which night lights are applied. Must be a systemd timer, see systemd.time(7).";
    };

    endTime = mkOption {
      default = "*-*-* 6:00:00";
      type = types.nonEmptyStr;
      description = "The time at which night lights are removed. Must be a systemd timer, see systemd.time(7).";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services = {
      "start-nightlights" = {
        Unit = {
          Description = "Start night lights";
        };

        Service = {
          Type = "oneshot";
          ExecStart = "${getExe cfg.package}";
        };
      };

      "stop-nightlights" = {
        Unit = {
          Description = "Stop night lights";
        };

        Service = {
          Type = "oneshot";
          ExecStart = "${getExe cfg.package} --stop";
        };
      };
    };

    systemd.user.timers = {
      "start-nightlights" = {
        Unit = {
          Description = "timer to start night lights";
        };

        Timer = {
          OnCalendar = [cfg.startTime];
          Persistent = true;
        };

        Install = {
          WantedBy = ["timers.target"];
        };
      };

      "stop-nightlights" = {
        Unit = {
          Description = "timer to stop night lights";
        };

        Timer = {
          OnCalendar = [cfg.endTime];
          Persistent = true;
        };

        Install = {
          WantedBy = ["timers.target"];
        };
      };
    };
  };
}
