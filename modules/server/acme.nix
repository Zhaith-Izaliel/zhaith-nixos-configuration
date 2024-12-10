{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  cfg = config.hellebore.server.acme;
in {
  options.hellebore.server.acme = {
    enable = mkEnableOption "ACME support";

    email = mkOption {
      type = types.nonEmptyStr;
      default = "";
      description = "The email used to renew the certificates";
    };
  };

  config = mkIf cfg.enable {
    security.acme = {
      acceptTerms = true;
      defaults = {
        inherit (cfg) email;
        renewInterval = "*-*-* 02:00:00 Europe/Paris";
      };
    };
  };
}
