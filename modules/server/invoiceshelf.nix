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

      mail = {
        username = mkOption {
          default = "";
          type = types.nonEmptyStr;
          description = "The no-reply account username to send mail from.";
        };

        mail = mkOption {
          default = "";
          type = types.nonEmptyStr;
          description = "The no-reply account mail address to send mail from.";
        };

        encryption = mkOption {
          default = "none";
          type = types.enum ["tls" "none" "ssl" "starttls"];
          description = "The encryption level of the SMTP server.";
        };

        passwordFile = mkOption {
          default = "";
          type = types.path;
          description = ''
            The file containing the mail account password, in the form:
            ```
              password
            ```
          '';
        };

        port = mkOption {
          type = types.ints.unsigned;
          default = 25;
          description = "The port of the mail server to use.";
        };

        host = mkOption {
          type = types.nonEmptyStr;
          default = "";
          description = "The host of the mail server to use.";
        };
      };
    }
    // extra-types.server-app {
      inherit domain;
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
          SESSION_DOMAIN = cfg.domain;
          SANCTUM_STATEFUL_DOMAINS = cfg.domain;
          APP_URL = "https://${cfg.domain}";
          APP_FORCE_HTTPS = "true";
          PHP_TZ = config.time.timeZone;
          TIMEZONE = config.time.timeZone;
          DB_CONNECTION = "pgsql";
          DB_HOST = "10.0.2.2";
          DB_PORT = toString config.services.postgresql.settings.port;
          DB_DATABASE = cfg.database;
          DB_USERNAME = cfg.user;
          STARTUP_DELAY = "0";
          MAIL_DRIVER = "smtp";
          MAIL_HOST = cfg.mail.host;
          MAIL_PORT = toString cfg.mail.port;
          MAIL_USERNAME = cfg.mail.username;
          MAIL_ENCRYPTION = cfg.mail.encryption;
          MAIL_FROM_NAME = "Invoiceshelf";
          MAIL_FROM_ADDRESS = cfg.mail.mail;
        };

        environmentFiles = [
          cfg.secretEnvFile
          cfg.mail.passwordFile
        ];

        extraOptions = [
          "--network"
          "slirp4netns:allow_host_loopback=true"
        ];
      };
    };

    hellebore.server.nginx.enable = mkDefault true;

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "/" = {
          proxyPass = "http://localhost:${toString cfg.port}";
        };
      };
    };

    services.postgresql = {
      enable = mkDefault true;
      ensureDatabases = [cfg.database];

      ensureUsers = [
        {
          name = cfg.user;
          ensureDBOwnership = true;
        }
      ];
      authentication = ''
        host ${cfg.database} ${cfg.user} 10.88.0.0/16 md5
      '';
    };
  };
}
