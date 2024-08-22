{
  config,
  lib,
  extra-types,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkDefault mkOption types;
  cfg = config.hellebore.server.ghost;
  domain = "${cfg.subdomain}.${config.networking.domain}";
  databaseService = "mysql.service";

  setupScript = pkgs.writeScriptBin "ghost-setup.sh" ''
    chmod g+s "${cfg.dataDir}"
    [[ ! -d "${cfg.dataDir}/content" ]] && cp -r "${pkgs.ghost-publishing}/content" "${cfg.dataDir}/content"
    chown -R "${cfg.user}":"${cfg.group}" "${cfg.dataDir}/content"
    chmod -R +w "${cfg.dataDir}/content"
    ln -f -s "/etc/ghost.json" "${cfg.dataDir}/config.production.json"
    [[ -d "${cfg.dataDir}/current" ]] && rm "${cfg.dataDir}/current"
    ln -f -s "${pkgs.ghost-publishing}/current" "${cfg.dataDir}/current"
    [[ -d "${cfg.dataDir}/content/themes/casper" ]] && rm "${cfg.dataDir}/content/themes/casper"
    ln -f -s "${pkgs.ghost-publishing}/current/content/themes/casper" "${cfg.dataDir}/content/themes/casper"
  '';
in {
  options.hellebore.server.ghost =
    {
      dataDir = mkOption {
        default = "/var/lib/ghost";
        description = lib.mdDoc "Directory to store Ghost data.";
        type = types.nonEmptyStr;
      };
    }
    // extra-types.server-app {
      name = "Ghost";
      user = "ghost";
      group = "ghost";
      database = "ghost";
      package = "ghost-publishing";
      port = 9000;
    };

  config = mkIf cfg.enable {
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

    services.mysql = {
      ensureDatabases = [cfg.database];
      ensureUsers = [
        {
          name = cfg.user;
          ensurePermissions = {"${cfg.database}.*" = "ALL PRIVILEGES";};
        }
      ];
    };

    # Creates the user and group
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      createHome = true;
      home = cfg.dataDir;
    };
    users.groups.${cfg.group} = {};

    # Creates the Ghost config
    environment.etc."ghost.json".text = ''
      {
        "url": "https://${domain}",
        "server": {
          "port": toString cfg.port,
          "host": "0.0.0.0"
        },
        "database": {
          "client": "mysql",
          "connection": {
            "host": "localhost",
            "user": cfg.user,
            "database": cfg.database,
            "password": "",
            "socketPath": "/run/mysqld/mysqld.sock"
          }
        },
        "mail": {
          "transport": "sendmail"
        },
        "logging": {
          "transports": ["stdout"]
        },
        "paths": {
          "contentPath": "${cfg.dataDir}/content"
        }
      }
    '';

    # Sets up the Systemd service
    systemd.services.ghost = {
      enable = true;
      description = "Independent technology for modern publishing, memberships, subscriptions and newsletters.";
      restartIfChanged = true;
      restartTriggers = [cfg.package config.environment.etc."ghost.json".source];
      requires = [databaseService];
      after = [databaseService];
      path = [pkgs.nodejs pkgs.vips];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;
        # Executes the setup script before start
        ExecStartPre = setupScript;
        # Runs Ghost with node
        ExecStart = "${pkgs.nodejs}/bin/node current/index.js";
        # Sandboxes the Systemd service
        AmbientCapabilities = [];
        CapabilityBoundingSet = [];
        KeyringMode = "private";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "full";
        RemoveIPC = true;
        RestrictAddressFamilies = [];
        RestrictNamespaces = true;
        RestrictRealtime = true;
      };
      environment = {NODE_ENV = "production";};
    };
  };
}
