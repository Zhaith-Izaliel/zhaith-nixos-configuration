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

      monitoring = {
        enable =
          mkEnableOption null
          // {
            description = ''
              Allow system monitoring through Dash. Since Dash. is served without any authentication, it is unsafe to open it up through the reverse proxy, as such Homarr should access it through `localhost:${toString cfg.monitoring.port}`.
            '';
          };

        port = mkOption {
          type = types.ints.unsigned;
          default = 3001;
          description = "The port to serve Dash. on.";
        };

        settings = mkOption {
          type = types.attrsOf types.str;
          default = {};
          description = ''
            The configuration for Dash. It is an attributes set of environment variables.
            See https://getdashdot.com/docs/configuration/basic
          '';
        };

        volume = mkOption {
          default = "/var/lib/dashdot";
          description = lib.mdDoc "Directory to store Dash. volume.";
          type = types.nonEmptyStr;
        };
      };

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
            BASE_URL = cfg.domain;
          }
          // (mkIf cfg.authentication.OIDC.enable {
            AUTH_PROVIDER = "oidc";
            AUTH_OIDC_URI = "https://${autheliaCfg.domain}";
            AUTH_OIDC_CLIENT_ID = cfg.authentication.OIDC.clientId;
            AUTH_OIDC_CLIENT_NAME = "Authelia";
            AUTH_OIDC_ADMIN_GROUP = "homarr-admin";
            AUTH_OIDC_OWNER_GROUP = "homarr-owner";
            NEXTAUTH_URL = "https://${cfg.domain}/";
          });

        environmentFiles = optional cfg.authentication.OIDC.enable cfg.authentication.OIDC.clientSecretFile;

        extraOptions = [
          "--network"
          "slirp4netns:allow_host_loopback=true"
        ];
      };

      dashdot = mkIf cfg.monitoring.enable {
        image = "mauricenino/dashdot:latest";
        volumes = [
          "/:${cfg.monitoring.volume}:ro"
        ];
        ports = [
          "${toString cfg.monitoring.port}:${toString cfg.monitoring.port}/tcp"
        ];
        extraOptions = [
          "--privileged"
        ];

        environment =
          cfg.monitoring.settings
          // {
            DASHDOT_PORT = toString cfg.monitoring.port;
          };
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
                  "https://${domain}/api/auth/callback/oidc"
                  "http://localhost:${toString cfg.port}/api/auth/callback/oidc"
                ];
                scopes = ["openid" "profile" "email" "groups"];
                userinfo_signed_response_alg = "none";
                response_types = ["code"];
                consent_mode = "implicit";
                token_endpoint_auth_method = "client_secret_basic";
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

      serverAliases = optional cfg.redirectMainDomainToHomarr config.networking.domain;

      default = cfg.redirectUndefinedSubdomainsToHomarr;

      locations = {
        "/" = {
          proxyPass = "http://localhost:${toString cfg.port}";
        };
      };
    };
  };
}
