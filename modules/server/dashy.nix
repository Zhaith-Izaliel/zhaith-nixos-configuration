{
  config,
  lib,
  extra-types,
  pkgs,
  ...
}: let
  inherit (lib) mkIf types mkOption mkDefault getExe concatStringsSep mapAttrsToList recursiveUpdate mkEnableOption pipe;
  cfg = config.hellebore.server.dashy;
  autheliaCfg = config.hellebore.server.authelia;
  domain = "${cfg.subdomain}.${config.networking.domain}";

  yamlFormat = pkgs.formats.yaml {};

  replace-secret =
    if cfg.secrets == null
    then ""
    else
      pipe cfg.secrets [
        (mapAttrsToList (
          name: value: ''${getExe pkgs.replace-secret} "${name}" "${value}" "${configLocation}"''
        ))
        (concatStringsSep "\n")
      ];

  configLocation = "${cfg.volume}/conf.yml";

  moduleSettings = {
    appConfig = {
      auth = {
        enableOidc = true;
        oidc = {
          clientId = cfg.domain;
          endpoint = "https://${autheliaCfg.domain}/api/oidc/authorization";
          scope = cfg.authentication.OIDC.scopes;
        };
      };
    };
  };

  finalConfig = yamlFormat.generate "dashy-conf.yml" (recursiveUpdate cfg.settings moduleSettings);

  preStart = ''
    mkdir -p ${cfg.volume}
    install --mode=600 --owner=1000 --group=root "${finalConfig}" "${configLocation}"
    ${replace-secret}
  '';
in {
  options.hellebore.server.dashy =
    {
      volume = mkOption {
        type = types.nonEmptyStr;
        default = "/var/lib/dashy";
      };

      settings = mkOption {
        type = yamlFormat.type;
        default = {
          pageInfo = {
            title = "Dashy";
            description = "Welcome to your new dashboard!";
            navLinks = [
              {
                title = "GitHub";
                path = "https://github.com/Lissy93/dashy";
              }
              {
                title = "Documentation";
                path = "https://dashy.to/docs";
              }
            ];
          };
          appConfig = {theme = "colorful";};
          sections = [
            {
              name = "Getting Started";
              icon = "fas fa-rocket";
              items = [
                {
                  title = "Dashy Live";
                  description = "Development a project management links for Dashy";
                  icon = "https://i.ibb.co/qWWpD0v/astro-dab-128.png";
                  url = "https://live.dashy.to/";
                  target = "newtab";
                }
                {
                  title = "GitHub";
                  description = "Source Code, Issues and Pull Requests";
                  url = "https://github.com/lissy93/dashy";
                  icon = "favicon";
                }
                {
                  title = "Docs";
                  description = "Configuring & Usage Documentation";
                  provider = "Dashy.to";
                  icon = "far fa-book";
                  url = "https://dashy.to/docs";
                }
                {
                  title = "Showcase";
                  description = "See how others are using Dashy";
                  url = "https://github.com/Lissy93/dashy/blob/master/docs/showcase.md";
                  icon = "far fa-grin-hearts";
                }
                {
                  title = "Config Guide";
                  description = "See full list of configuration options";
                  url = "https://github.com/Lissy93/dashy/blob/master/docs/configuring.md";
                  icon = "fas fa-wrench";
                }
                {
                  title = "Support";
                  description = "Get help with Dashy, raise a bug, or get in contact";
                  url = "https://github.com/Lissy93/dashy/blob/master/.github/SUPPORT.md";
                  icon = "far fa-hands-helping";
                }
              ];
            }
          ];
        };
        description = "Configuration for Dashy written as yaml in the corresponding `configLocation`.";
      };

      setDomainAsDefault =
        mkEnableOption null
        // {
          description = "Wether to set the domain as the default domain for Nginx.";
        };

      authentication.OIDC = {
        scopes = mkOption {
          default = [
            "openid"
            "profile"
            "roles"
            "email"
            "groups"
          ];
          readOnly = true;
          type = types.listOf types.nonEmptyStr;
          description = "The scope used in OIDC auth. Read-only.";
        };
      };

      secrets = mkOption {
        type = types.nullOr (types.attrsOf types.path);
        default = null;
        description = ''
          Defines secrets for Dashy in the form `{ placeholder = "path/to/file" }` where:
          - `placeholder` corresponds to the placeholder used in your `settings` for the corresponding secrets, i.e. "@password_placeholder@"
          - `path/to/file` corresponds to the file containing the secret. The file must be only readable for the user/group defined in the module.
        '';
      };
    }
    // extra-types.server-app {
      inherit domain;
      name = "Dashy";
      user = "dashy";
      group = "dashy";
      port = 0661;
    };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = autheliaCfg.enable;
        message = "Authelia should be enabled and configured using its Hellebore's module for Dashy to work properly";
      }
    ];

    virtualisation.oci-containers.containers = {
      dashy = {
        image = "lissy93/dashy";

        environment = {
          NODE_ENV = "production";
        };

        volumes = [
          "${cfg.volume}:/user-data"
        ];

        ports = [
          "${toString cfg.port}:8080/tcp"
        ];

        log-driver = "journald";
      };
    };

    systemd.services.podman-dashy = {
      inherit preStart;
      # serviceConfig = {
      #   User = cfg.user;
      #   Group = cfg.group;
      # };
    };

    hellebore.server.nginx.enable = mkDefault true;

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      enableACME = true;
      default = cfg.setDomainAsDefault;
      locations = {
        "/" = {
          proxyPass = "http://localhost:${toString cfg.port}";
        };
      };
    };

    services.authelia.instances.${autheliaCfg.instance} = {
      settings = {
        identity_providers = {
          oidc = {
            clients = [
              {
                client_id = cfg.domain;
                client_name = "Dashy";
                public = true;
                authorization_policy = "two_factor";
                redirect_uris = [
                  "https://${cfg.domain}"
                ];
                grant_types = ["authorization_code"];
                scopes = cfg.authentication.OIDC.scopes;
                require_pkce = true;
                pkce_challenge_method = "S256";
              }
            ];
          };
        };
      };
    };
  };
}
