{
  config,
  lib,
  extra-types,
  ...
}: let
  inherit (lib) mkIf mkDefault mkOption types mdDoc;
  cfg = config.hellebore.server.outline;
  domain = "${cfg.subdomain}.${config.networking.domain}";
in {
  options.hellebore.server.outline =
    {
      storagePath = mkOption {
        default = "/var/lib/outline/data";
        description = mdDoc "Directory to store Invoiceshelf volume.";
        type = types.nonEmptyStr;
      };

      logo = mkOption {
        default = null;
        description = mdDoc "Custom logo displayed on the authentication screen. This will be scaled to a height of 60px.";
        type = types.nullOr types.path;
      };

      secrets = {
        databaseURLFile = mkOption {
          type = types.path;
          default = null;
          description = mdDoc ''
            An environment file containing the database URl in the form:

            ```bash
            DATABASE_URL="http://outline:password@localhost:5432"
            ```
            Note: the port, user and host have to be coherent with configuration, generally it should be `http://outline:password@localhost:5432`
          '';
        };

        redisUrlFile = mkOption {
          type = types.path;
          default = null;
          description = "";
        };
      };
    }
    // (extra-types.server-app {
      inherit domain;
      name = "Outline";
      package = "outline";
      group = "outline";
      user = "outline";
      database = "outline";
      port = 3000;
    });

  config = mkIf cfg.enable {
    services.outline = {
      inherit (cfg) group user package port logo;
      enable = true;

      publicUrl = "https://${cfg.domain}";
      # databaseUrl = "http://${cfg.user}@localhost:${toString config.services.postgresql.settings.port}";
      databaseUrl = "local";

      storage = {
        storageType = "local";
        localRootDir = cfg.storagePath;
      };
    };

    hellebore.server.nginx.enable = mkDefault true;

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;

      locations = {
        "/" = {
          proxyPass = "http://localhost:${toString cfg.port}";
          extraConfig = ''
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;proxy_set_header Host $host;
            proxy_redirect off;
          '';
        };
      };
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [cfg.database];

      ensureUsers = [
        {
          name = cfg.user;
          ensureDBOwnership = true;
        }
      ];
    };
  };
}
