{
  config,
  lib,
  extra-types,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkDefault mkOption types mdDoc;
  cfg = config.hellebore.server.outline;
  domain = "${cfg.subdomain}.${config.networking.domain}";
  autheliaCfg = config.hellebore.server.authelia;
in {
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/security/authelia.nix"
  ]; # COMPATIBILITY: Move to Authelia unstable for Outline OIDC to work

  disabledModules = ["services/security/authelia.nix"];

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

      OIDC = {
        clientId = mkOption {
          type = types.nonEmptyStr;
          default = "";
          description = ''
            A string corresponding to your client ID for OIDC authentication in Authelia. It should be generated as follows:

            ```bash
            authelia crypto rand --length 72 --charset rfc3986
            ```
          '';
        };
        clientSecretFile = mkOption {
          type = types.path;
          default = null;
          description = ''
            A file containing the client secret for OIDC authentication. The secret should be generated as follows (it should be the first line printed by the command, see https://www.authelia.com/integration/openid-connect/frequently-asked-questions/#client-secret) and the file should be encrypted using Agenix:

            ```bash
              authelia crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986
            ```
          '';
        };

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

      oidcAuthentication = {
        inherit (cfg.OIDC) clientSecretFile clientId;

        displayName = "Authelia";
        tokenUrl = "https://${autheliaCfg.domain}/api/oidc/token";
        userinfoUrl = "https://${autheliaCfg.domain}/api/oidc/userinfo";
        authUrl = "https://${autheliaCfg.domain}/api/oidc/authorization";
        scopes = ["openid" "offline_access" "profile" "email"];
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

    services.authelia.instances.${config.hellebore.server.authelia.instance} = {
      settings = {
        identity_providers = {
          oidc = {
            clients = [
              {
                client_id = cfg.OIDC.clientId;
                client_secret = cfg.OIDC.hashedClientSecret;
                client_name = "Outline";
                public = false;
                authorization_policy = "two_factor";
                redirect_uris = [
                  "https://outline.ethereal-edelweiss.cloud/auth/oidc.callback"
                ];
                scopes = ["openid" "offline_access" "profile" "email"];
                userinfo_signed_response_alg = "none";
                token_endpoint_auth_method = "client_secret_post";
              }
            ];
          };
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
