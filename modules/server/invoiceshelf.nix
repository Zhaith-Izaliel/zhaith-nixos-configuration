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

      secretEnvFile = mkOption {
        default = "";
        type = types.path;
        description = ''
          The env file containing the DB password, in the form:
          ```
            DB_PASSWORD="password"
          ```
        '';
      };
    }
    // extra-types.server-app {
      name = "InvoiceShelf";
      user = "invoiceshelf";
      database = "invoiceshelf";
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
          SESSION_DOMAIN = domain;
          SANCTUM_STATEFUL_DOMAINS = domain;
          APP_URL = "https://${domain}";
          APP_FORCE_HTTPS = "true";
          PHP_TZ = config.time.timeZone;
          TIMEZONE = config.time.timeZone;
          DB_CONNECTION = "pgsql";
          DB_HOST = "10.0.2.2";
          DB_PORT = toString config.services.postgresql.settings.port;
          DB_DATABASE = "invoiceshelf";
          DB_USERNAME = cfg.user;
          STARTUP_DELAY = "0";
        };

        environmentFiles = [
          cfg.secretEnvFile
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
          recommendedProxyConfig = true;
        };
      };
    };

    services.postgresql.authentication = ''
      host ${cfg.database} ${cfg.user} 10.88.0.0/16 md5
    '';
  };
}
