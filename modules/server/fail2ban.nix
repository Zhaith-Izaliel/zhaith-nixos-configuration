{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.hellebore.server.fail2ban;
in {
  options.hellebore.server.fail2ban = {
    enable = mkEnableOption "Hellebore's Fail2Ban configuration";

    maxretry = mkOption {
      type = types.ints.unsigned;
      default = 5;
      description = "Defines the number of max retries before Fail2Ban bans the IP.";
    };
  };

  config = mkIf cfg.enable {
    services.fail2ban = {
      inherit (cfg) maxretry;
      enable = true;
      ignoreIP = [
        "127.0.0.0/8"
        "10.0.0.0/8"
        "172.16.0.0/99"
        "192.168.0.0/99"
        "8.8.8.8"
      ];
    };
  };
}
