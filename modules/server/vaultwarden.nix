{
  config,
  lib,
  extra-types,
  ...
}: let
  inherit (lib) mkOption types mkIf cleanSource mkDefault mkEnableOption concatStringsSep;
  cfg = config.hellebore.server.vaultwarden;
  domain = "${cfg.subdomain}.${config.networking.domain}";
in {
  options.hellebore.server.vaultwarden =
    {
      backupDir = mkOption {
        type = types.path;
        default = cleanSource /var/calibre/library;
        description = "The directory under which vaultwarden will backup its persistent data.";
      };

      secretEnvFile = mkOption {
        default = "";
        type = types.path;
        description = ''
          The file containing the secrets, in the form:
          ```
            PGPASSWORD=password
            SMTP_PASSWORD=password
            ADMIN_TOKEN=token
          ```
        '';
      };

      registration = {
        enable = mkEnableOption "user registration through the login page";

        domainsWhitelist = mkOption {
          default = [];
          type = types.listOf types.nonEmptyStr;
          description = "The email domains allowed to restrict registration. If you set this up, `config.hellebore.vaultwarden.registration.enable` will be ignored.";
        };
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

        security = mkOption {
          default = "off";
          type = types.enum [
            "starttls"
            "force_tls"
            "off"
          ];
          description = "The level of security used for the SMTP mail server. It's generally better to force TLS.";
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
      name = "Vaultwarden";
      package = "vaultwarden";
      port = 8222;
    };

  config = mkIf cfg.enable {
    services.vaultwarden = {
      inherit (cfg) package backupDir;
      enable = true;
      dbBackend = "postgresql";
      config = {
        ROCKET_PORT = cfg.port;
        ROCKET_ADDRESS = "127.0.0.1";
        PGHOST = "locahost";
        PGPORT = toString config.services.postgresql.settings.port;
        PGUSER = "vaultwarden";
        PGDATABASE = "vaultwarden";
        SMTP_HOST = cfg.mail.host;
        SMTP_FROM = "Vaultwarden <${cfg.mail.mail}>";
        SMTP_PORT = toString cfg.mail.port;
        SMTP_SECURITY = cfg.mail.security;
        SMTP_USERNAME = cfg.mail.username;
        SIGNUPS_DOMAINS_WHITELIST = concatStringsSep "," cfg.registration.domainsWhitelist;
        SIGNUPS_ALLOWED =
          if cfg.registration.enable
          then "true"
          else "false";
      };

      environmentFile = cfg.secretEnvFile;
    };

    hellebore.server.nginx.enable = mkDefault true;
    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };

    services.postgresql = {
      enable = mkDefault true;
      ensureDatabases = ["vaultwarden"];

      ensureUsers = [
        {
          name = "vaultwarden";
          ensureDBOwnership = true;
        }
      ];
    };

    services.fail2ban.jails = {
      vaultwarden = {
        filter = {
          INCLUDES.before = "common.conf";

          Definition = {
            failregex = ''^.*?Username or password is incorrect\. Try again\. IP: <ADDR>\. Username:.*$'';
          };
        };

        settings = {
          enable = true;
          port = "80,443,${toString cfg.port}";
          banaction = "%(banaction_allports)s";
          backend = "systemd";
          filter = ''vaultwarden[journalmatch='_SYSTEMD_UNIT=vaultwarden.service']'';
          maxretry = 3;
          bantime = 14400;
          findtime = 14400;
        };
      };

      vaultwarden-admin = {
        filter = {
          INCLUDES.before = "common.conf";

          Definition = {
            failregex = ''^.*Invalid admin token\. IP: <ADDR>.*$'';
          };
        };

        settings = {
          enable = true;
          port = "80,443";
          banaction = "%(banaction_allports)s";
          backend = "systemd";
          filter = ''vaultwarden-admin[journalmatch='_SYSTEMD_UNIT=vaultwarden.service']'';
          maxretry = 3;
          bantime = 14400;
          findtime = 14400;
        };
      };
    };
  };
}
