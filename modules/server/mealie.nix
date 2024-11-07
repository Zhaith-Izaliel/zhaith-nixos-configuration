{
  config,
  lib,
  extra-types,
  ...
}: let
  inherit (lib) mkOption types mkIf cleanSource mkDefault toUpper;
  cfg = config.hellebore.server.mealie;
  domain = "${cfg.subdomain}.${config.networking.domain}";
in {
  options.hellebore.server.mealie =
    {
      library = mkOption {
        type = types.path;
        default = cleanSource /var/calibre/library;
        description = "";
      };

      secretEnvFile = mkOption {
        default = "";
        type = types.path;
        description = ''
          The env file containing the passwords and secrets, in the form:
          ```
            POSTGRES_PASSWORD="password"
            SMTP_PASSWORD=""
            # Generated with `authelia crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986`
            OIDC_CLIENT_SECRET=""
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
          type = types.enum ["tls" "none" "ssl"];
          description = "The encryption level of the SMTP server.";
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

      authentication.OIDC = {
        hashedClientSecret = mkOption {
          type = types.nonEmptyStr;
          default = "";
          description = ''
            The **hashed** client secret for OIDC authentication. The secret should be generated as follows (it should be the second line printed by the command, see https://www.authelia.com/integration/openid-connect/frequently-asked-questions/#client-secret for more info):

            ```bash
              authelia crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986
            ```
          '';
        };

        adminGroup = mkOption {
          type = types.nonEmptyStr;
          default = "mealie-admins";
          description = "The group where Mealie's admins belong to.";
        };

        userGroup = mkOption {
          type = types.nonEmptyStr;
          default = "mealie-users";
          description = "The group where Mealie's users belong to.";
        };
      };
    }
    // extra-types.server-app {
      inherit domain;
      name = "Mealie";
      package = "mealie";
      group = "mealie";
      user = "mealie";
      database = "mealie";
      port = 9000;
    };

  config = mkIf cfg.enable {
    services.mealie = {
      inherit (cfg) package port;
      enable = true;
      credentialsFile = cfg.secretEnvFile;
      settings = {
        TZ = config.time.timeZone;
        DB_ENGINE = "postgres";
        POSTGRES_USER = cfg.user;
        POSTGRES_SERVER = "localhost";
        POSTGRES_PORT = toString config.services.postgresql.settings.port;
        POSTGRES_DB = cfg.database;
        SMTP_HOST = cfg.mail.host;
        SMTP_PORT = cfg.mail.port;
        SMTP_FROM_NAME = "Mealie";
        SMTP_FROM_EMAIL = cfg.mail.mail;
        SMTP_USER = cfg.mail.user;
        SMTP_AUTH_STRATEGY = toUpper cfg.mail.encryption;
        OIDC_AUTH_ENABLED = "true";
        OIDC_SIGNUP_ENABLED = "true";
        OIDC_CONFIGURATION_URL = "https://${config.hellebore.server.authelia.domain}/.well-known/openid-configuration";
        OIDC_CLIENT_ID = cfg.domain;
        OIDC_AUTO_REDIRECT = "false";
        OIDC_ADMIN_GROUP = cfg.authentication.OIDC.adminGroup;
        OIDC_USER_GROUP = cfg.authentication.OIDC.userGroup;
      };
    };

    systemd.services.mealie = {
      User = cfg.user;
      Group = cfg.group;
    };

    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
    };

    users.groups.${cfg.group} = {};

    hellebore.server.nginx.enable = mkDefault true;
    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}";
      };
    };

    services.authelia.instances.${config.hellebore.server.authelia.instance} = {
      settings = {
        identity_providers = {
          oidc = {
            clients = [
              {
                client_id = cfg.domain;
                client_secret = cfg.authentication.OIDC.hashedClientSecret;
                client_name = "Mealie";
                public = false;
                authorization_policy = "two_factor";
                redirect_uris = [
                  "https://${cfg.domain}/login"
                ];
                scopes = ["openid" "profile" "email" "groups"];
                userinfo_signed_response_alg = "none";
                # response_types = ["code" "token"];
                # token_endpoint_auth_method = "client_secret_post";
              }
            ];
          };
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
        host ${cfg.database} ${cfg.user} 127.0.0.1 md5
      '';
    };
  };
}
