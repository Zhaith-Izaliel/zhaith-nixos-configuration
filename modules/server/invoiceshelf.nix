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
        default = "";
        type = types.nonEmptyStr;
        description = ''
          The env file containing the DB password, in the form:
          ```
            DB_PASSWORD="password"
          ```
        '';
      };

      sessionDomain = mkOption {
        default = "host.containers.internal";
        type = types.nonEmptyStr;
        description = "Defines the session domain, corresponding to the container IP, usually `host.containers.internal`.";
      };
    }
    // extra-types.server-app {
      name = "InvoiceShelf";
      group = "invoiceshelf";
      port = 0660;
    };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      invoiceshelf = {
        image = "invoiceshelf/invoiceshelf";

        volumes = [
          "${cfg.volume}:/data"
        ];

        ports = [
          "${toString cfg.port}:80"
        ];

        environment = {
          APP_ENV = "production";
          SESSION_DOMAIN = cfg.sessionDomain;
          SANCTUM_STATEFUL_DOMAINS = cfg.sessionDomain;
          APP_URL = "http://${cfg.sessionDomain}";
          PHP_TZ = config.time.timeZone;
          TIMEZONE = config.time.timeZone;
          DB_CONNECTION = "pgsql";
          DB_HOST = "10.0.2.2";
          DB_PORT = toString config.services.postgresql.port;
          DB_DATABASE = "invoiceshelf";
          DB_USERNAME = cfg.user;
          STARTUP_DELAY = "0";
        };

        environmentFiles = [
          cfg.dbPasswordFile
        ];

        extraOptions = [
          "--network"
          "slirp4netns:allow_host_loopback=true"
        ];
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
      host invoiceshelf invoiceshelf 10.88.0.0/16 md5
    '';

    security.acme = {
      acceptTerms = true;
      certs = {
        ${domain}.email = cfg.acmeEmail;
      };
    };
  };
}
