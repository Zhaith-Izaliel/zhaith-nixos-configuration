{
  config,
  lib,
  extra-types,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkDefault mkOption types getExe recursiveUpdate;
  jsonFormat = pkgs.formats.json {};

  cfg = config.hellebore.server.ghost;
  domain = "${cfg.subdomain}.${config.networking.domain}";

  defaultConfig = {
    database = {
      client = "mysql";
      connection = {
        database = cfg.database;
        host = "10.0.2.2";
        port = "3306";
        user = cfg.user;
        password = "@dbpass@";
      };
    };
    url = "https://${domain}";
  };

  configLocation = "${cfg.volume}/config.production.json";

  replace-secret = ''${getExe pkgs.replace-secret} "${defaultConfig.database.connection.password}" "${cfg.dbPass}" "${configLocation}"'';

  finalConfig = jsonFormat.generate "ghost-config.production.json" (recursiveUpdate cfg.settings defaultConfig);

  preStart = ''
    mkdir -p "${cfg.volume}"
    install --mode=600 --owner=$USER "${finalConfig}" "${configLocation}"
    ${replace-secret}
  '';
in {
  options.hellebore.server.ghost =
    {
      volume = mkOption {
        default = "/var/lib/ghost";
        description = lib.mdDoc "Directory to store Ghost data.";
        type = types.nonEmptyStr;
      };
      dbPass = mkOption {
        default = "";
        type = types.path;
        description = ''
          The file containing the Database password, in the form:
          ```
            password
          ```
        '';
      };

      settings = mkOption {
        type = jsonFormat.type;
        default = {};
        description = ''
          The settings used on this Ghost instance. Refer to https://ghost.org/docs/config/ to configure Ghost.

          **Do not override database or url configuration with these.**
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

      volumes = [
        "${cfg.volume}:/var/lib/ghost"
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

    systemd.services.podman-ghost = {
      inherit preStart;
    };

    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
    };

    users.groups.${cfg.group} = {};

    services.mysql = {
      ensureDatabases = [cfg.database];
      # ensureUsers = [
      #   {
      #     name = cfg.user;
      #     ensurePermissions = {"${cfg.database}.*" = "ALL PRIVILEGES";};
      #   }
      # ];
    };
  };
}
