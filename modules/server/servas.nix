{
  config,
  lib,
  extra-types,
  ...
}: let
  inherit (lib) mkIf types mkOption mkDefault;
  cfg = config.hellebore.server.servas;
  domain = "${cfg.subdomain}.${config.networking.domain}";
in {
  options.hellebore.server.servas =
    {
      volume = mkOption {
        default = "/var/lib/servas";
        description = ''
          Directory to store the Servas volume.
        '';
        type = types.nonEmptyStr;
      };

      allowRegistration = mkOption {
        default = true;
        type = types.bool;
        description = "Allow external users to register to Servas.";
      };

      secretEnvFile = mkOption {
        default = "";
        type = types.path;
        description = ''
          The env file containing the App Key, in the form:
          ```
            APP_KEY="base64:key"
          ```

          It should be generated the first time with
          `sudo podman exec -it servas php artisan key:generate --force`
        '';
      };
    }
    // extra-types.server-app {
      name = "Servas";
      user = "servas";
      group = "servas";
      port = 8090;
    };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      servas = {
        image = "beromir/servas";

        volumes = [
          "${cfg.volume}:/var/www/html/database/sqlite"
          "${cfg.secretEnvFile}:/var/www/html/.env"
        ];

        ports = [
          "${toString cfg.port}:80"
        ];

        environment = {
          APP_NAME = cfg.name;
          APP_ENV = "production";
          SERVAS_ENABLE_REGISTRATION =
            if cfg.allowRegistration
            then "true"
            else "false";
          APP_DEBUG = "false";
          APP_URL = "https://${domain}";
          DB_CONNECTION = "sqlite";
          DB_DATABASE = "/var/www/html/database/sqlite/servas.db";
          DB_FOREIGN_KEYS = "true";
        };

        environmentFiles = [
          cfg.secretEnvFile
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
  };
}
