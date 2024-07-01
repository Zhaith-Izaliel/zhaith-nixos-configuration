{
  config,
  lib,
  extra-types,
  ...
}: let
  inherit (lib) mkIf types mkOption mkDefault;
  cfg = config.hellebore.server.twentycrm;

  domain = "${cfg.subdomain}.${config.networking.domain}";

  database-host = "10.0.2.2:${toString config.services.postgresql.settings.port}";

  volumes = [
    "${cfg.volume}/server-local-data:/app/packages/twenty-server/.local-storage"
    "${cfg.volume}/docker-data:/app/docker-data"
  ];

  default-env = rec {
    PORT = toString cfg.port;
    SERVER_URL = "https://${domain}";
    FRONT_BASE_URL = SERVER_URL;
    MESSAGE_QUEUE_TYPE = "pg-boss";
    STORAGE_TYPE = "local";
    SIGN_IN_PREFILLED = "true";
    PG_DATABASE_HOST = database-host;
    PG_DATABASE_URL = ''postgres://${cfg.user}:${cfg.user}@${database-host}/${cfg.database}'';
  };
in {
  options.hellebore.server.twentycrm =
    {
      volume = mkOption {
        default = "/var/lib/twentycrm";
        description = "Directory to store Twenty CRM volume.";
        type = types.nonEmptyStr;
      };

      user = mkOption {
        default = "twentycrm";
        type = types.nonEmptyStr;
        description = "Defines the user running Twenty CRM.";
      };

      secretEnvFile = mkOption {
        default = "";
        type = types.nonEmptyStr;
        description = ''
          The env file containing the secret tokens, in the form:
          ```
          ACCESS_TOKEN_SECRET="string1"
          LOGIN_TOKEN_SECRET="string2"
          REFRESH_TOKEN_SECRET="string3"
          FILE_TOKEN_SECRET="string4"
          POSTGRES_ADMIN_PASSWORD="db_password"
          ```

          Where every strings are generated using `openssl rand -base64 32`.
        '';
      };
    }
    // extra-types.server-app {
      name = "Twenty CRM";
      group = "twentycrm";
      port = 3000;
      database = "twentycrm";
    };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      twentycrm = {
        inherit volumes;
        image = "twentycrm/twenty";

        ports = [
          "${toString cfg.port}:3000"
        ];

        environment =
          {
            ENABLE_DB_MIGRATIONS = "true";
          }
          // default-env;

        environmentFiles = [
          cfg.secretEnvFile
        ];

        extraOptions = [
          "--network"
          "slirp4netns:allow_host_loopback=true"
        ];

        dependsOn = ["twentycrm-change-volume-ownership"];
      };

      twentycrm-change-volume-ownership = {
        inherit volumes;
        image = "ubuntu";

        user = "root";

        cmd = [
          ''
            bash -c "chown -R 1000:1000 /tmp/server-local-data && chown -R 1000:1000 /tmp/docker-data"
          ''
        ];
      };

      twentycrm-worker = {
        image = "twentycrm/twenty";

        cmd = [
          "yarn"
          "worker:prod"
        ];

        environment =
          {
            ENABLE_DB_MIGRATIONS = "false"; # it already runs on the server
          }
          // default-env;

        environmentFiles = [
          cfg.secretEnvFile
        ];

        extraOptions = [
          "--network"
          "slirp4netns:allow_host_loopback=true"
        ];

        dependsOn = ["twentycrm"];
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
      host ${cfg.user} ${cfg.database} 10.88.0.0/16 md5
    '';
  };
}
