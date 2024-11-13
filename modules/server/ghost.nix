{
  config,
  lib,
  extra-types,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkDefault mkOption types getExe recursiveUpdate mkEnableOption;
  jsonFormat = pkgs.formats.json {};

  cfg = config.hellebore.server.ghost;
  domain = "${cfg.subdomain}.${config.networking.domain}";

  defaultConfig = {
    url = "https://${cfg.domain}";
    database = {
      client = "mysql";
      connection = {
        database = cfg.database;
        host = "10.0.2.2";
        port = "3306";
        user = cfg.user;
        password = "@database_password_placeholder@";
      };
    };
    server = {
      port = 2368;
      host = "::";
    };
    mail = {
      transport = "SMTP";
      options = {
        inherit (cfg.mail) host port secure;
        service = "ethereal-edelweiss.cloud";
        from = "Ghost <${cfg.mail.mail}>";
        auth = {
          user = cfg.mail.username;
          pass = "@mail_account_pass_placeholder@";
        };
      };
    };
    logging = {
      transports = [
        "file"
        "stdout"
      ];
    };
    process = "systemd";
    paths = {
      contentPath = "/var/lib/ghost/content";
    };
  };

  configLocation = "${cfg.volume}/config/config.production.json";

  replace-secret = ''
    ${getExe pkgs.replace-secret} "${defaultConfig.database.connection.password}" "${cfg.dbPass}" "${configLocation}"
    ${getExe pkgs.replace-secret} "${defaultConfig.mail.options.auth.pass}" "${cfg.mail.passwordFile}" "${configLocation}"
  '';

  finalConfig = jsonFormat.generate "ghost-config.production.json" (recursiveUpdate cfg.settings defaultConfig);

  preStart = ''
    mkdir -p "${cfg.volume}"/{content,config}
    install --mode=600 --owner=${cfg.user} --group=${cfg.group} "${finalConfig}" "${configLocation}"
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

        secure =
          mkEnableOption null
          // {
            description = "Wether to force the use of Submissions (SSL) instead of default STARTTLS or SMTP.";
          };

        passwordFile = mkOption {
          default = "";
          type = types.path;
          description = ''
            The file containing the mail account password, in the form:
            ```
              password
            ```
          '';
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
        "${cfg.volume}/content:/var/lib/ghost/content"
        "${configLocation}:/var/lib/ghost/config.production.json"
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

    services.nginx.virtualHosts.${cfg.domain} = {
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
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
      };
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
