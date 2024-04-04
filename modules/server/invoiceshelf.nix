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

      dbPasswordFile = mkOption {
        default = "/var/lib/invoiceshelf/db-pass";
        type = types.nonEmptyStr;
        description = "File used to store the database password. Must be only readable by root";
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

      user = "${cfg.user}:${cfg.group}";

      volumes = [
        "./invoiceshelf/data:${cfg.volume}"
      ];

      ports = [
        "90:${toString cfg.port}"
      ];

      environment = {
        PHP_TZ = config.time.timeZone;
        TIMEZONE = config.time.timeZone;
        DB_CONNECTION = "pgsql";
        DB_HOST = "127.0.0.1";
        DB_PORT = toString config.services.postgresql.port;
        DB_DATABASE = "invoiceshelf";
        DB_USERNAME = cfg.user;
        DB_PASSWORD_FILE = cfg.dbPasswordFile;
        STARTUP_DELAY = "30";
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

      extraConfig = ''
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header X-Robots-Tag none;
        add_header Content-Security-Policy "frame-ancestors 'self'";
        charset utf-8;
      '';
    };

    security.acme = {
      acceptTerms = true;
      certs = {
        ${domain}.email = cfg.acmeEmail;
      };
    };
  };
}
