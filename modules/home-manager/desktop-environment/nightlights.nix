{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types mkPackageOption getExe concatStringsSep;
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

    extraArgs = mkOption {
      default = [];
      type = types.listOf types.nonEmptyStr;
      description = "Extra arguments to pass to hyprsunset.";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services = {
      "nightlights" = {
        Unit = {
          Description = "nightlights";
        };

        Service = {
          Type = "oneshot";
          ExecStart = "${getExe cfg.package} ${concatStringsSep " " cfg.extraArgs}";
        };
      };
    };

    systemd.user.timers = {
      "nightlights" = {
        Unit = {
          Description = "nightlights timer";
        };

        Timer = {
          OnCalendar = [cfg.startTime cfg.endTime];
        };

        Install = {
          WantedBy = ["timers.target"];
        };
      };
    };
  };
}
