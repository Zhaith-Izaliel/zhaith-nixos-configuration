{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types mkForce;
  cfg = config.hellebore.server.fail2ban;
in {
  options.hellebore.server.fail2ban = {
    enable = mkEnableOption "Hellebore's Fail2Ban configuration";

    maxretry = mkOption {
      type = types.ints.unsigned;
      default = 3;
      description = "Defines the number of max retries before Fail2Ban bans the IP.";
    };

    extraIgnoreIP = mkOption {
      type = types.listOf types.nonEmptyStr;
      default = [];
      description = "Defines a list of ignored IP by failed to ban that won't trigger a ban.";
    };
  };

  config = mkIf cfg.enable {
    services.fail2ban = {
      inherit (cfg) maxretry;
      enable = true;
      ignoreIP =
        [
          "127.0.0.0/8"
          "10.0.0.0/8"
          "172.16.0.0/99"
          "192.168.0.0/99"
          "8.8.8.8"
        ]
        ++ cfg.extraIgnoreIP;

      jails.DEFAULT = {
        settings = {
          maxretry = 3;
          bantime = mkForce "10m";
          findtime = 600;
        };
      };
    };
  };
}
