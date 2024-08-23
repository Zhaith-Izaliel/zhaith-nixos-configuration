{
  config,
  lib,
  extra-types,
  ...
}: let
  inherit (lib) mkIf mkDefault mkOption types;
  cfg = config.hellebore.server.ghost;
  domain = "${cfg.subdomain}.${config.networking.domain}";
in {
  options.hellebore.server.ghost =
    {
      volume = mkOption {
        default = "/var/lib/ghost";
        description = lib.mdDoc "Directory to store Ghost data.";
        type = types.nonEmptyStr;
      };
      secretEnvFile = mkOption {
        default = "";
        type = types.path;
        description = ''
          The env file containing the DB password, in the form:
          ```
            database__connection__password="password"
          ```
        '';
      };
    }
    // extra-types.server-app {
      name = "Ghost";
      user = "ghost";
      group = "ghost";
      database = "ghost";
      port = 2368;
    };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers."ghost" = {
      image = "ghost";
      environment = {
        "database__client" = "mysql";
        "database__connection__database" = cfg.database;
        "database__connection__host" = "localhost";
        "database__connection__port" = "3306";
        "database__connection__user" = cfg.user;
        "url" = "https://${domain}";
        "mail__transport" = "sendmail";
      };

      environmentFiles = [
        cfg.secretEnvFile
      ];

      volumes = [
        "${cfg.volume}:/var/lib/ghost/content:rw"
      ];

      ports = [
        "${toString cfg.port}:2368/tcp"
      ];

      log-driver = "journald";
      extraOptions = [
        "--network"
        "slirp4netns:allow_host_loopback=true"
      ];
    };

    hellebore.server.nginx.enable = mkDefault true;

    services.nginx.virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;

      extraConfig = ''
        charset UTF-8;

        add_header Strict-Transport-Security "max-age=2592000; includeSubDomains" always;
        add_header Referrer-Policy "strict-origin-when-cross-origin";
        add_header X-Frame-Options "SAMEORIGIN";
        add_header X-XSS-Protection "1; mode=block";
        add_header X-Content-Type-Options nosniff;
      '';

      locations = {
        "/" = {
          proxyPass = "http://localhost:${toString cfg.port}";
        };
      };
    };

    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
    };

    users.groups.${cfg.group} = {};

    services.mysql = {
      ensureDatabases = [cfg.database];
      ensureUsers = [
        {
          name = cfg.user;
          ensurePermissions = {"${cfg.database}.*" = "ALL PRIVILEGES";};
        }
      ];
    };
  };
}
