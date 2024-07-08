{
  config,
  lib,
  extra-types,
  ...
}: let
  inherit (lib) mkIf types mkOption mkDefault;
  cfg = config.hellebore.server.cozy;
  domain = "${cfg.subdomain}.${config.networking.domain}";

  environment = {
    DOMAIN = domain;
    COUCHDB_PROTOCOL = "http";
    # COUCHDB_HOST = network.couchdbAlias;
    COUCHDB_HOST = "localhost";
    COUCHDB_PORT = toString 5984;
    COUCHDB_USER = cfg.user;
    COZY_SUBDOMAIN_TYPE = cfg.subdomainType;
  };

  environmentFiles = [
    cfg.secretEnvFile
  ];
in {
  options.hellebore.server.cozy =
    {
      admin = {
        subdomain = mkOption {
          type = types.nonEmptyStr;
          default = "admin";
          description = "Defines the admin interface subdomain.";
        };

        port = mkOption {
          type = types.ints.unsigned;
          default = 6060;
          description = "Defines the port of the admin interface";
        };
      };

      volume = mkOption {
        default = "/var/lib/cozy";
        description = ''
          Directory to store Cozy volume.

          Should contain these subdirectories:
          - `data`
          - `config`
          - `couchdb`
        '';
        type = types.nonEmptyStr;
      };

      secretEnvFile = mkOption {
        default = null;
        type = types.path;
        description = ''
          The env file containing the secrets for Cozy, in the form:
          ```
          COUCHDB_PASSWORD="SomeRandomlyGeneratedPassword"
          COZY_ADMIN_PASSPHRASE="AnotherRandomlyGeneratedPassword"
          ```

          This file should be encrypted with agenix and not serve in plain text to the NixOS Store.
        '';
      };

      subdomainType = mkOption {
        default = "nested";
        type = types.enum ["nested" "flat"];
        description = ''
          Application subdomain type for each Cozy.
          Could be nested (https://<app>.<instance>.<domain>) or flat (https://<instance>-<app>.<domain>)
        '';
      };

      installedApps = mkOption {
        default = [
          "home"
          "banks"
          "contacts"
          "drive"
          "notes"
          "passwords"
          "photos"
          "settings"
          "store"
          "mespapiers"
        ];
        type = types.listOf (types.enum [
          "home"
          "banks"
          "contacts"
          "drive"
          "notes"
          "passwords"
          "photos"
          "settings"
          "store"
          "mespapiers"
        ]);
        description = ''
          The apps installed on the instance. Should at least contain `home`, `settings`, `store`.
        '';
      };
    }
    // extra-types.server-app {
      name = "Cozy";
      user = "cozy";
      group = "cozy";
      database = "cozy";
      port = 8089;
    };

  config = mkIf cfg.enable {
    # Containers
    virtualisation.oci-containers.containers = {
      "cozy-stack" = {
        inherit environment environmentFiles;
        image = "cozy/cozy-stack";

        volumes = [
          "${cfg.volume}/config:/etc/cozy:rw"
          "${cfg.volume}/data:/var/lib/cozy/data:rw"
        ];

        ports = [
          "${toString cfg.port}:8080/tcp"
          "${toString cfg.admin.port}:6060/tcp"
        ];

        dependsOn = [
          "cozy-couchdb"
        ];

        log-driver = "journald";

        extraOptions = [
          "--health-cmd=[ \"$(curl -fsSL http://localhost:8080/status | jq -r .status)\" = \"OK\" ]"
          "--health-interval=10s"
          "--health-retries=3"
          "--health-start-period=30s"
          "--health-timeout=5s"
          # "--network-alias=${network.cozyAlias}"
          "--network=host"
        ];
      };
    };

    hellebore.server.nginx.enable = mkDefault true;

    services.nginx.virtualHosts = {
      "${domain}" = {
        forceSSL = true;
        enableACME = true;
        extraConfig = ''
          add_header Strict-Transport-Security "max-age=31536000; includeSubDomains;";
          client_max_body_size 1g;
        '';

        serverAliases = builtins.map (item: "${item}.${domain}") cfg.installedApps;

        locations = {
          "/" = {
            proxyPass = "http://localhost:${toString cfg.port}";
          };
        };
      };
    };
  };
}
