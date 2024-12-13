{
  config,
  os-config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkIf types concatStringsSep mkEnableOption mkPackageOption getExe;
  cfg = config.hellebore.multimedia.sonobus;
in {
  options.hellebore.multimedia.sonobus = {
    enable = mkEnableOption "Sonobus";

    package = mkPackageOption pkgs "sonobus" {};

    service = {
      enable = mkEnableOption "Sonobus as a systemd service, running in headless mode.";

      setupFile = mkOption {
        default = null;
        type = types.path;
        description = "Path to the audio setup for Sonobus";
      };

      groupName = mkOption {
        type = types.nonEmptyStr;
        default = "";
        description = "The name of the Sonobus group to automatically connect to.";
      };

      target = mkOption {
        type = types.str;
        default = "default.target";
        description = ''
          The systemd target that will automatically start the Sonobus service.
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [];
        description = "Extra arguments to use on the service.";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = os-config.hellebore.sound.enable;
        description = "You must enable sound support in your OS configuration.";
      }
    ];

    home.packages = [cfg.package];

    systemd.user.services.sonobus = mkIf cfg.service.enable {
      Unit = {
        Description = "Headless Sonobus daemon";
        Wants = [
          "pipewire.service"
          "network.target"
        ];
      };

      Service = {
        ExecStart = ''${getExe cfg.package} --headless --group="${cfg.service.groupName}" --load-setup ${cfg.service.setupFile} ${concatStringsSep " " cfg.service.extraArgs}'';
        ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
        Restart = "on-failure";
      };

      Install = {WantedBy = [cfg.service.target];};
    };
  };
}
