{
  config,
  lib,
  extra-types,
  ...
}: let
  inherit (lib) mkIf types mkOption mkDefault;
  cfg = config.hellebore.server.invoiceshelf;
  domain = "${cfg.subdomain}.${config.networking.domain}";
in {
  options.hellebore.server.invoiceshelf =
    {
      volume = mkOption {
        default = "/var/lib/invoiceshelf";
        description = lib.mdDoc "Directory to store Invoiceshelf volume.";
        type = types.nonEmptyStr;
      };

      user = mkOption {
        default = "invoiceshelf";
        type = types.nonEmptyStr;
        description = "Defines the user running InvoiceShelf.";
      };
    }
    // extra-types.server-app {
      name = "InvoiceShelf";
      group = "invoiceshelf";
      port = 0660;
    };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.invoiceshelf = {
      image = "invoiceshelf/invoiceshelf";

      volumes = [
        "./invoiceshelf/data:${cfg.volume}"
      ];

      ports = [
        "${toString cfg.port}:80"
      ];

      environment = {
        PHP_TZ = config.time.timeZone;
        TIMEZONE = config.time.timeZone;
        DB_CONNECTION = "pgsql";
        DB_HOST = "localhost";
        DB_PORT = toString config.services.postgresql.port;
        DB_DATABASE = "invoiceshelf";
        DB_USERNAME = cfg.user;
        STARTUP_DELAY = "0";
      };
    };

    hellebore.server.nginx.enable = mkDefault true;

    services.nginx.virtualHosts.${domain} = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "/" = {
          proxyPass = "http://localhost:${toString cfg.port}";
        };
      };
    };

    services.postgresql.authentication = ''
      host invoiceshelf invoiceshelf 172.17.0.0/16 md5
    '';

    security.acme = {
      acceptTerms = true;
      certs = {
        ${domain}.email = cfg.acmeEmail;
      };
    };
  };
}
