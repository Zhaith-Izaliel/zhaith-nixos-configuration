{
  config,
  lib,
  extra-types,
  ...
}: let
  inherit (lib) mkIf types mkOption mkDefault;
  cfg = config.hellebore.server.twentycrm;
  domain = "${cfg.subdomain}.${config.networking.domain}";
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
          FILE_TOKEN_SECRET="string3"
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
        image = "twentycrm/twenty";

        volumes = [
          "${cfg.volume}:/app/\${STORAGE_LOCAL_PATH:-.local-storage}"
        ];

        ports = [
          "${toString cfg.port}:3000"
        ];

        environment = {
          PORT = toString cfg.port;
          ENABLE_DB_MIGRATIONS = "true";
          SERVER_URL = "https://${domain}";
          PG_DATABASE_URL = "postgres://twenty:twenty@10.0.2.2:${toString config.services.postgresql.port}/default";
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
        };
      };
    };

    services.postgresql.authentication = ''
      host ${cfg.user} ${cfg.database} 10.88.0.0/16 md5
    '';

    security.acme = {
      acceptTerms = true;
      certs = {
        ${domain}.email = cfg.acmeEmail;
      };
    };
  };
}
