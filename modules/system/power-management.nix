{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkMerge mkIf getExe;
  cfg = config.hellebore.power-management;
  upower-notify = pkgs.go-upower-notify.overrideAttrs (prev: {
    src = pkgs.fetchFromGitHub {
      owner = "omeid";
      repo = "upower-notify";
      rev = "7013b0d4d2687e03554b1287e566dc8979896ea5";
      sha256 = "sha256-8kGMeWIyM6ML1ffQ6L+SNzuBb7e5Y5I5QKMkyEjSVEA=";
    };
  });
in {
  options.hellebore.power-management = {
    enable = mkEnableOption "Hellebore's power management module";

    autoShutdown = {
      enable = mkEnableOption "Auto-Shutdown";

      cronTemplate = mkOption {
        type = types.nonEmptyStr;
        default = "";
        description = "Cron template used to define the time at which point the
        shutdown occurs.";
      };

      reminders = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [];
        description = "A list of Cron templates to show a reminder of the
        scheduled shutdown";
      };

      shutdownDate = mkOption {
        type = types.nonEmptyStr;
        default = "";
        description = "Set the GNU shutdown datetime.";
      };
    };

    upower = {
      enable = mkEnableOption "UPower support";

      notify = mkEnableOption "UPower to send desktop notifications.";

      percentageLow = mkOption {
        type = types.ints.unsigned;
        default = 10;
        description = lib.mdDoc ''
          When `usePercentageForPolicy` is
          `true`, the levels at which UPower will consider the
          battery low.

          This will also be used for batteries which don't have time information
          such as that of peripherals.

          If any value (of `percentageLow`,
          `percentageCritical` and
          `percentageAction`) is invalid, or not in descending
          order, the defaults will be used.
        '';
      };

      percentageCritical = mkOption {
        type = types.ints.unsigned;
        default = 3;
        description = lib.mdDoc ''
          When `usePercentageForPolicy` is
          `true`, the levels at which UPower will consider the
          battery critical.

          This will also be used for batteries which don't have time information
          such as that of peripherals.

          If any value (of `percentageLow`,
          `percentageCritical` and
          `percentageAction`) is invalid, or not in descending
          order, the defaults will be used.
        '';
      };

      percentageAction = mkOption {
        type = types.ints.unsigned;
        default = 2;
        description = lib.mdDoc ''
          When `usePercentageForPolicy` is
          `true`, the levels at which UPower will take action
          for the critical battery level.

          This will also be used for batteries which don't have time information
          such as that of peripherals.

          If any value (of `percentageLow`,
          `percentageCritical` and
          `percentageAction`) is invalid, or not in descending
          order, the defaults will be used.
        '';
      };

      criticalPowerAction = mkOption {
        type = types.enum ["PowerOff" "Hibernate" "HybridSleep"];
        default = "HybridSleep";
        description = lib.mdDoc ''
          The action to take when `timeAction` or
          `percentageAction` has been reached for the batteries
          (UPS or laptop batteries) supplying the computer
        '';
      };

      ignoreLid = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc ''
          Do we ignore the lid state

          Some laptops are broken. The lid state is either inverted, or stuck
          on or off. We can't do much to fix these problems, but this is a way
          for users to make the laptop panel vanish, a state that might be used
          by a couple of user-space daemons. On Linux systems, see also
          logind.conf(5).
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable && cfg.autoShutdown.enable) {
      services.cron = {
        enable = true;
        systemCronJobs =
          [
            "${cfg.autoShutdown.cronTemplate} root ${getExe pkgs.power-management} ${cfg.autoShutdown.shutdownDate}"
          ]
          ++ builtins.map
          (template: "${template} root ${getExe pkgs.power-management} --show")
          cfg.autoShutdown.reminders;
      };
    })

    (mkIf (cfg.enable && cfg.upower.enable) {
      services.upower = {
        inherit
          (cfg.upower)
          ignoreLid
          criticalPowerAction
          percentageLow
          percentageCritical
          percentageAction
          ;
        enable = true;
        usePercentageForPolicy = true;
      };

      systemd.user.services.upower-notify = {
        enable = cfg.upower.notify;

        path = with pkgs; [
          dbus
        ];

        script = "${upower-notify}/bin/upower-notify --notification-expiration 3s";

        wantedBy = [
          "graphical-session.target"
        ];

        wants = [
          "upower.service"
        ];
      };
    })
  ];
}
