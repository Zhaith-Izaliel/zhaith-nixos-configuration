{
  config,
  lib,
  extra-types,
  pkgs,
  ...
}: let
  inherit (lib) mkIf types mkOption mkDefault;
  cfg = config.hellebore.server.cozy;
  domain = "${cfg.subdomain}.${config.networking.domain}";
  adminDomain = "${cfg.admin.subdomain}.${domain}";

  environment = {
    DOMAIN = domain;
    COUCHDB_PROTOCOL = "http";
    COUCHDB_HOST = network.couchdbAlias;
    COUCHDB_PORT = toString 5984;
    COUCHDB_USER = cfg.user;
    COZY_SUBDOMAIN_TYPE = cfg.subdomainType;
  };

  environmentFiles = [
    cfg.secretEnvFile
  ];

  network = {
    name = "cozy_default";
    couchdbAlias = "cozy-couchdb";
    cozyAlias = "cozy-stack";
  };
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

      instanceName = mkOption {
        default = "";
        type = types.nonEmptyStr;
        description = "The cozy instance name to be created";
      };

      subdomainType = mkOption {
        default = "flat";
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
      "cozy-couchdb" = {
        inherit environment environmentFiles;
        image = "couchdb:3.3";

        volumes = [
          "${cfg.volume}/couchdb:/opt/couchdb/data:rw"
        ];

        log-driver = "journald";

        extraOptions = [
          ''--health-cmd=["curl","-f","${environment.COUCHDB_PROTOCOL}://localhost:${environment.COUCHDB_PORT}/_up"]''
          "--health-interval=10s"
          "--health-retries=3"
          "--health-start-period=30s"
          "--health-timeout=5s"
          "--network-alias=${network.couchdbAlias}"
          "--network=${network.name}"
        ];
      };

      "cozy-stack" = {
        inherit environment environmentFiles;
        image = "cozy/cozy-stack";

        cmd = [
          "cozy-stack"
          "serve"
          "--couchdb-url"
          "${environment.COUCHDB_PROTOCOL}://${environment.COUCHDB_HOST}:${environment.COUCHDB_PORT}"
        ];

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
          "--network-alias=${network.cozyAlias}"
          "--network=${network.name}"
        ];
      };
    };

    systemd.services = {
      "podman-cozy-couchdb" = {
        serviceConfig = {
          Restart = lib.mkOverride 500 "always";
        };
        after = [
          "podman-network-${network.name}.service"
        ];
        requires = [
          "podman-network-${network.name}.service"
        ];
        partOf = [
          "podman-compose-cozy-root.target"
        ];
        wantedBy = [
          "podman-compose-cozy-root.target"
        ];
      };

      "podman-cozy-stack" = {
        serviceConfig = {
          Restart = lib.mkOverride 500 "always";
        };
        after = [
          "podman-network-${network.name}.service"
        ];
        requires = [
          "podman-network-${network.name}.service"
        ];
        partOf = [
          "podman-compose-cozy-root.target"
        ];
        wantedBy = [
          "podman-compose-cozy-root.target"
        ];
      };

      # Networks
      "podman-network-${network.name}" = {
        path = [pkgs.podman];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStop = "${pkgs.podman}/bin/podman network rm -f ${network.name}";
        };
        script = ''
          podman network inspect ${network.name} || podman network create ${network.name}
        '';
        partOf = ["podman-compose-cozy-root.target"];
        wantedBy = ["podman-compose-cozy-root.target"];
      };
    };

    # Root service
    # When started, this will automatically create all resources and start
    # the containers. When stopped, this will teardown all resources.
    systemd.targets."podman-compose-cozy-root" = {
      unitConfig = {
        Description = "Root target generated by compose2nix.";
      };
      wantedBy = ["multi-user.target"];
    };

    hellebore.server.nginx.enable = mkDefault true;

    services.nginx.virtualHosts = {
      "${domain}" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            proxyPass = "http://localhost:${toString cfg.port}";
          };
        };

        serverAliases = builtins.map (item:
          if cfg.subdomainType == "flat"
          then "${cfg.instanceName}-${item}.${domain}"
          else "${item}.${cfg.instanceName}.${domain}")
        cfg.installedApps;
      };

      "${adminDomain}" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            proxyPass = "http://localhost:${toString cfg.admin.port}";
          };
        };
      };
    };
  };
}
