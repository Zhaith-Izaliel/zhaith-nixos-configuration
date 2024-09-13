{
  config,
  lib,
  extra-types,
  ...
}: let
  inherit (lib) mkIf types mkOption mkDefault mkEnableOption optional;
  cfg = config.hellebore.server.homarr;
  domain = "${cfg.subdomain}.${config.networking.domain}";
  mkVolume = name: (mkOption {
    default = "/var/lib/homarr/${name}";
    description = lib.mdDoc "Directory to store Homarr's ${name} as a Podman volume.";
    type = types.nonEmptyStr;
  });
  autheliaCfg = config.hellebore.server.authelia;
in {
  options.hellebore.server.homarr =
    {
      volumes = {
        data = mkVolume "data";
        configs = mkVolume "configs";
        icons = mkVolume "icons";
      };

      redirectMainDomainToHomarr = mkEnableOption "NGINX redirecting main domain name to Homarr";

      redirectUndefinedSubdomainsToHomarr = mkEnableOption "NGINX redirecting undefined subdomains to Homarr";

      podmanIntegration = mkEnableOption "Homarr's Podman integration. This exposes `/var/run/podman/podman.sock` to Homarr";

      authentication = {
        expiryTime = mkOption {
          type = types.nonEmptyStr;
          default = "30d";
          description = "Time for the session to time out. Can be set as pure number, which will automatically be used in seconds, or followed by s, m, h or d for seconds, minutes, hours or days. (ex: \"30m\")";
        };

        OIDC = {
          enable = mkEnableOption "OIDC authentication via Authelia. **This will disable basic credential authentication**";

          clientId = mkOption {
            type = types.nonEmptyStr;
            default = cfg.domain;
            description = "The client ID used for OIDC, by default its the domain.";
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
      };
    }
    // extra-types.server-app {
      inherit domain;
      name = "Homarr";
      user = "homarr";
      group = "homarr";
      port = 7575;
    };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      homarr = {
        image = "ghcr.io/ajnart/homarr:latest";

        volumes =
          [
            "${cfg.volumes.configs}:/app/data/configs:rw"
            "${cfg.volumes.data}:/data:rw"
            "${cfg.volumes.icons}:/app/public/icons:rw"
          ]
          ++ optional cfg.podmanIntegration "/var/run/podman/podman.sock:/var/run/docker.sock:rw";

        ports = [
          "${toString cfg.port}:7575/tcp"
        ];

        environment =
          {
            TZ = config.time.timeZone;
            DISABLE_ANALYTICS = "true";
            AUTH_SESSION_EXPIRY_TIME = cfg.authentication.expiryTime;
          }
          // (mkIf cfg.authentication.OIDC.enable {
            AUTH_PROVIDER = "oidc";
            AUTH_OIDC_URI = autheliaCfg.domain;
            AUTH_OIDC_CLIENT_ID = cfg.authentication.OIDC.clientId;
            AUTH_OIDC_CLIENT_NAME = "Authelia";
            AUTH_LOGOUT_REDIRECT_URL = autheliaCfg.domain;
          });

        environmentFiles = optional cfg.authentication.OIDC.enable cfg.authentication.OIDC.clientSecretFile;
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
                client_name = "Homarr";
                public = false;
                authorization_policy = "two_factor";
                redirect_uris = [
                  "https://${domain}/auth/oidc.callback"
                ];
                scopes = ["openid" "profile" "email" "offline_access" "groups"];
                userinfo_signed_response_alg = "none";
                response_types = ["code" "token"];
                token_endpoint_auth_method = "client_secret_post";
              }
            ];
          };
        };
      };
    };

    hellebore.server.nginx.enable = mkDefault true;

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      enableACME = true;

      serverAliases = (optional cfg.redirectMainDomainToHomarr config.networking.domain) ++ (optional cfg.redirectUndefinedSubdomainsToHomarr "*.${config.networking.domain}");

      locations = {
        "/" = {
          proxyPass = "http://localhost:${toString cfg.port}";
        };
      };
    };
  };
}
