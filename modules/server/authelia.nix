{
  config,
  lib,
  extra-types,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkDefault types mkOption;
  cfg = config.hellebore.server.authelia;
  domain = "${cfg.subdomain}.${config.networking.domain}";
  mkSecretOption = name: formOfFile:
    mkOption {
      type = types.path;
      default = null;
      description = ''
        A file containing the ${name}, in the form:

        ```
        ${formOfFile}
        ```

        **It should be encrypted using Agenix, otherwise it will be stored in plain text in the world readable Nix Store.**
      '';
    };

  nginxConfigs = {
    OIDC = {
      serverConfig = {
        locations."/internal/authelia/authz/basic" = {
          proxyPass = "http://localhost:${toString cfg.port}/api/verify";

          recommendedProxySettings = false;

          extraConfig = ''
            ## Essential Proxy Configuration
            internal;

            proxy_pass_request_body off;
            proxy_set_header Content-Length "";

            # Timeout if the real server is dead
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
            client_body_buffer_size 128k;
            proxy_set_header Host $host;
            proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header X-Forwarded-Uri $request_uri;
            proxy_set_header X-Forwarded-Ssl on;
            proxy_redirect  http://  $scheme://;
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            proxy_cache_bypass $cookie_session;
            proxy_no_cache $cookie_session;
            proxy_buffers 4 32k;

            send_timeout 5m;
            proxy_read_timeout 240;
            proxy_send_timeout 240;
            proxy_connect_timeout 240;
          '';
        };
      };

      locationConfig = {
        extraConfig = ''
          auth_request /authelia;
          auth_request_set $target_url https://$http_host$request_uri;
          auth_request_set $user $upstream_http_remote_user;
          auth_request_set $email $upstream_http_remote_email;
          auth_request_set $groups $upstream_http_remote_groups;
          proxy_set_header Remote-User $user;
          proxy_set_header Remote-Email $email;
          proxy_set_header Remote-Groups $groups;

          error_page 401 =302 https://${cfg.domain}/?rd=$target_url;

          client_body_buffer_size 128k;

          proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;

          send_timeout 5m;
          proxy_read_timeout 360;
          proxy_send_timeout 360;
          proxy_connect_timeout 360;

          proxy_set_header Host $host;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection upgrade;
          proxy_set_header Accept-Encoding gzip;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $http_host;
          proxy_set_header X-Forwarded-Uri $request_uri;
          proxy_set_header X-Forwarded-Ssl on;
          proxy_redirect  http://  $scheme://;
          proxy_http_version 1.1;
          proxy_set_header Connection "";
          proxy_cache_bypass $cookie_session;
          proxy_no_cache $cookie_session;
          proxy_buffers 64 256k;
        '';
      };
    };

    basicAuth = {
      serverConfig = {
        locations."/internal/authelia/authz/basic" = {
          proxyPass = "http://localhost:${toString cfg.port}/api/authz/auth-request/basic";
          recommendedProxySettings = false;
          extraConfig = ''
            ## Essential Proxy Configuration
            internal;

            ## Headers
            ## The headers starting with X-* are required.
            proxy_set_header X-Original-Method $request_method;
            proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
            proxy_set_header X-Original-Method $request_method;
            proxy_set_header X-Forwarded-Method $request_method;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header X-Forwarded-URI $request_uri;
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header Content-Length "";
            proxy_set_header Connection "";

            ## Basic Proxy Configuration
            proxy_pass_request_body off;
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503; # Timeout if the real server is dead
            proxy_redirect http:// $scheme://;
            proxy_http_version 1.1;
            proxy_cache_bypass $cookie_session;
            proxy_no_cache $cookie_session;
            proxy_buffers 4 32k;
            client_body_buffer_size 128k;

            ## Advanced Proxy Configuration
            send_timeout 5m;
            proxy_read_timeout 240;
            proxy_send_timeout 240;
            proxy_connect_timeout 240;
          '';
        };
      };

      locationConfig = {
        extraConfig = ''
          auth_request /internal/authelia/authz/basic;

          ## Save the upstream response headers from Authelia to variables.
          auth_request_set $user $upstream_http_remote_user;
          auth_request_set $groups $upstream_http_remote_groups;
          auth_request_set $name $upstream_http_remote_name;
          auth_request_set $email $upstream_http_remote_email;

          ## Inject the response headers from the variables into the request made to the backend.
          proxy_set_header Remote-User $user;
          proxy_set_header Remote-Groups $groups;
          proxy_set_header Remote-Name $name;
          proxy_set_header Remote-Email $email;
        '';
      };
    };
  };
in {
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/security/authelia.nix"
  ]; # COMPATIBILITY: Move to Authelia unstable for Outline OIDC to work

  disabledModules = ["services/security/authelia.nix"];

  options.hellebore.server.authelia =
    {
      instance = mkOption {
        type = types.nonEmptyStr;
        default = "main";
        readOnly = true;
        description = "The name of the Authelia instance. Read only.";
      };

      nginx = {
        basicAuth = {
          serverConfig = mkOption {
            type = types.attrs;
            default = nginxConfigs.basicAuth.serverConfig;
            readOnly = true;
            description = "The NGINX configuration for locations using basic Authz with Authelia. Should be merged with `services.nginx.server.<name>`. Read only.";
          };

          locationConfig = mkOption {
            type = types.attrs;
            default = nginxConfigs.basicAuth.locationConfig;
            readOnly = true;
            description = ''The NGINX configuration for the app location using basic Authz with Authelia. Should be merged with `services.nginx.server.<name>.locations."/"`. Read only.'';
          };
        };

        OIDC = {
          serverConfig = mkOption {
            type = types.attrs;
            default = nginxConfigs.OIDC.serverConfig;
            readOnly = true;
            description = "The NGINX configuration for locations using basic OIDC with Authelia. Should be merged with `services.nginx.server.<name>`. Read only.";
          };

          locationConfig = mkOption {
            type = types.attrs;
            default = nginxConfigs.OIDC.locationConfig;
            readOnly = true;
            description = ''The NGINX configuration for the app location using basic OIDC with Authelia. Should be merged with `services.nginx.server.<name>.locations."/"`. Read only.'';
          };
        };
      };

      theme = mkOption {
        type = types.enum ["dark" "light" "grey" "auto"];
        default = "auto";
        description = "The theme used by Authelia";
      };

      secrets = {
        emailPasswordFile = mkSecretOption "Email Password for SMTP notifications" ''
          password
        '';

        oidcHmacSecretFile = mkSecretOption "OIDC Hmac secret" ''
          # Generated with
          # `authelia crypto hash generate argon2 --random --random.length 64 --random.charset alphanumeric`

          secret
        '';

        oidcIssuerPrivateKeyFile = mkSecretOption "OIDC JSON Web Key" ''
          # Generated with
          # `authelia crypto pair rsa generate`

          secret
        '';

        redisServerPasswordFile = mkSecretOption "Redis Server password" ''
          # Generated with
          # `authelia crypto hash generate argon2 --random --random.length 64 --random.charset alphanumeric`

          password
        '';

        databasePasswordFile = mkSecretOption "PostgreSQL database password" ''
          # Generated with
          # `authelia crypto hash generate argon2 --random --random.length 64 --random.charset alphanumeric`

          password
        '';

        jwtSecretFile = mkSecretOption "JWT Token" ''
          # Generated with
          # `authelia crypto hash generate argon2 --random --random.length 64 --random.charset alphanumeric`

          token
        '';
        sessionSecretFile = mkSecretOption "Session Secret" ''
          # Generated with
          # `authelia crypto hash generate argon2 --random --random.length 64 --random.charset alphanumeric`

          secret
        '';
        storageEncryptionKeyFile = mkSecretOption "Storage Encryption Key" ''
          # Generated with
          # `authelia crypto hash generate argon2 --random --random.length 64 --random.charset alphanumeric`

          key
        '';
        userDatabase = mkSecretOption "User Database" ''
          users:
          john:
            displayname: "John Doe"
            password: "argon encrypted password" # Generated with `authelia crypto hash generate argon2 --password 'yourpassword'`
            email: john.doe@authelia.com
            groups:
              - admins
              - dev
        '';
      };
    }
    // (extra-types.server-app {
      inherit domain;
      name = "Authelia";
      package = "authelia";
      user = "authelia";
      group = "authelia";
      database = "authelia";
      port = 9091;
    });

  config = mkIf cfg.enable {
    users = {
      users.${cfg.user} = {
        isSystemUser = true;
        group = cfg.group;
      };

      groups.${cfg.group} = {};
    };

    services.authelia.instances.${cfg.instance} = {
      inherit (cfg) package user group;
      enable = true;

      secrets = {
        inherit (cfg.secrets) jwtSecretFile sessionSecretFile storageEncryptionKeyFile oidcHmacSecretFile oidcIssuerPrivateKeyFile;
      };

      settings = {
        inherit (cfg) theme;
        server = {
          address = "tcp://0.0.0.0:${toString cfg.port}/";

          buffers = {
            read = 4096;
            write = 4096;
          };

          endpoints = {
            enable_pprof = false;

            enable_expvars = false;

            authz.auth-request.implementation = "AuthRequest";
          };

          disable_healthcheck = false;

          tls = {
            key = "";
            certificate = "";
          };
        };

        log = {level = "info";};

        totp = {
          issuer = cfg.domain;
          disable = false;
          algorithm = "sha1";
          digits = 6;
          period = 30;
          skew = 1;
          secret_size = 32;
          allowed_algorithms = ["SHA1"];
          allowed_digits = [6];
          allowed_periods = [30];
          disable_reuse_security_policy = false;
        };

        authentication_backend = {
          password_reset = {disable = false;};

          refresh_interval = "5m";

          file = {
            path = cfg.secrets.userDatabase;

            password = {
              algorithm = "argon2id";
              iterations = 1;
              key_length = 32;
              salt_length = 16;
              memory = 1024;
              parallelism = 8;
            };
          };
        };

        access_control = {
          default_policy = "deny";

          rules = [
            {
              domain = [cfg.domain];
              policy = "bypass";
            }
            {
              domain = ["*.${config.networking.domain}"];
              subject = ["group:admins"];
              policy = "one_factor";
            }
          ];
        };

        session = {
          name = "authelia_session";
          same_site = "lax";
          expiration = "1h";
          inactivity = "5m";
          remember_me = "2M";

          cookies = [
            {
              domain = config.networking.domain;
              authelia_url = "https://${cfg.domain}";
              default_redirection_url = "https://${config.networking.domain}/";
            }
          ];

          redis = {
            host = "localhost";
            password = ''{{ secret "${cfg.secrets.redisServerPasswordFile}" }}'';
            port = config.services.redis.servers.authelia.port;
            database_index = 0;
            maximum_active_connections = 10;
            minimum_idle_connections = 0;
          };
        };

        regulation = {
          max_retries = 3;
          find_time = "10m";
          ban_time = "12h";
        };

        storage = {
          postgres = {
            address = "tcp://localhost:${toString config.services.postgresql.settings.port}/";
            database = cfg.database;
            username = cfg.user;
            password = ''{{ secret "${cfg.secrets.databasePasswordFile}" }}'';
          };
        };

        notifier = {
          disable_startup_check = false;

          smtp = {
            address = "smtp://smtp.orange.fr:25";
            username = "ribeyre.virgil@orange.fr";
            password = ''{{ secret "${cfg.secrets.emailPasswordFile}" }}'';
            sender = "Authelia <no-reply@${config.networking.domain}>";
            identifier = "smtp.orange.fr";
            subject = "[Authelia] {title}";
            startup_check_address = "test@authelia.com";
            disable_require_tls = false;
            disable_html_emails = false;
            tls = {
              skip_verify = false;
              minimum_version = "TLS1.2";
            };
          };
        };

        identity_providers = {
          oidc = {
            lifespans = {
              access_token = "1h";
              authorize_code = "1m";
              id_token = "1h";
              refresh_token = "90m";
            };

            enable_client_debug_messages = false;
            enforce_pkce = "always";

            cors = {
              endpoints = ["authorization" "token" "revocation" "introspection" "userinfo"];
              allowed_origins = ["https://${cfg.domain}"];
              allowed_origins_from_client_redirect_uris = false;
            };
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
    };

    services.redis.servers.authelia = {
      enable = true;
      port = 9092;
      requirePassFile = cfg.secrets.redisServerPasswordFile;
    };

    hellebore.server.nginx.enable = mkDefault true;

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;

      locations = {
        "/" = {
          proxyPass = "http://localhost:${toString cfg.port}";
          recommendedProxySettings = false;

          extraConfig = ''
            ## Headers
            proxy_set_header Host $host;
            proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header X-Forwarded-URI $request_uri;
            proxy_set_header X-Forwarded-Ssl on;
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header X-Real-IP $remote_addr;

            ## Basic Proxy Configuration
            client_body_buffer_size 128k;
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503; ## Timeout if the real server is dead.
            proxy_redirect  http://  $scheme://;
            proxy_http_version 1.1;
            proxy_cache_bypass $cookie_session;
            proxy_no_cache $cookie_session;
            proxy_buffers 64 256k;

            ## Trusted Proxies Configuration
            ## Please read the following documentation before configuring this:
            ##     https://www.authelia.com/integration/proxies/nginx/#trusted-proxies
            # set_real_ip_from 10.0.0.0/8;
            # set_real_ip_from 172.16.0.0/12;
            # set_real_ip_from 192.168.0.0/16;
            # set_real_ip_from fc00::/7;
            real_ip_header X-Forwarded-For;
            real_ip_recursive on;

            ## Advanced Proxy Configuration
            send_timeout 5m;
            proxy_read_timeout 360;
            proxy_send_timeout 360;
            proxy_connect_timeout 360;
          '';
        };

        "/api/verify" = {
          proxyPass = "http://localhost:${toString cfg.port}";
        };

        "/api/authz/" = {
          proxyPass = "http://localhost:${toString cfg.port}";
        };
      };
    };
  };
}
