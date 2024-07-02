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

  environment = {
    DOMAIN = domain;
    COUCHDB_PROTOCOL = "http";
    COUCHDB_HOST = "localhost";
    COUCHDB_PORT = toString config.services.couchdb.port;
    COUCHDB_USER = cfg.user;
    COZY_SUBDOMAIN_TYPE = cfg.subdomainType;
  };

  environmentFiles = [
    cfg.secretEnvFile
  ];
in {
  options.hellebore.server.cozy =
    {
      volume = mkOption {
        default = "/var/lib/cozy";
        description = ''
          Directory to store Cozy volume.

          Should contain these subdirectories:
          - `data`
          - `config`
          - `couchdb/data`
          - `couchdb/etc`
        '';
        type = types.nonEmptyStr;
      };

      secretEnvFile = mkOption {
        default = "";
        type = types.nonEmptyStr;
        description = ''
          The env file containing the secrets for Cozy, in the form:
          ```
          COUCHDB_PASSWORD="SomeRandomlyGeneratedPassword"
          COZY_ADMIN_PASSPHRASE="AnotherRandomlyGeneratedPassword"
          ```
        '';
      };

      couchdb.adminConfig = mkOption {
        default = "";
        type = types.nonEmptyStr;
        description = ''
          The configuration file for couchdb allowing the cozy user defined in `hellebore.server.cozy.user` to be admin with its own password like:
          ```
           [admins]
           ${cfg.user} = SomeRandomlyGeneratedPassword
          ```
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
    virtualisation.oci-containers.containers = {
      cozy = {
        inherit environment environmentFiles;

        image = "cozy/cozy-stack";

        volumes = [
          "${cfg.volume}/data:/var/lib/cozy/data"
          "${cfg.volume}/config:/etc/cozy"
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
          "--network-alias=cozy"
          "--network=cozy_default"
        ];

        ports = [
          "${toString cfg.port}:8080"
        ];
      };

      cozy-couchdb = {
        inherit environment environmentFiles;

        image = "couchdb:3.3";

        volumes = [
          "${cfg.volume}/couchdb:/opt/couchdb/data"
        ];

        log-driver = "journald";

        extraOptions = [
          "--health-cmd=[\"curl\",\"-f\",\"://:@:/_up\"]"
          "--health-interval=10s"
          "--health-retries=3"
          "--health-start-period=30s"
          "--health-timeout=5s"
          "--network-alias=couchdb"
          "--network=cozy_default"
        ];
      };
    };

    # Networks
    systemd.services = {
      "podman-cozy-couchdb" = {
        serviceConfig = {
          Restart = lib.mkOverride 500 "always";
        };
        after = [
          "podman-network-cozy_default.service"
        ];
        requires = [
          "podman-network-cozy_default.service"
        ];
        partOf = [
          "podman-compose-cozy-root.target"
        ];
        wantedBy = [
          "podman-compose-cozy-root.target"
        ];
      };
      "podman-cozy" = {
        serviceConfig = {
          Restart = lib.mkOverride 500 "always";
        };
        after = [
          "podman-network-cozy_default.service"
        ];
        requires = [
          "podman-network-cozy_default.service"
        ];
        partOf = [
          "podman-compose-cozy-root.target"
        ];
        wantedBy = [
          "podman-compose-cozy-root.target"
        ];
      };

      "podman-network-cozy_default" = {
        path = [pkgs.podman];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStop = "${pkgs.podman}/bin/podman network rm -f cozy_default";
        };
        script = ''
          podman network inspect cozy_default || podman network create cozy_default
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

    services.nginx.virtualHosts."${domain}" = {
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

    # users.groups.${cfg.group} = {
    #   name = cfg.group;
    # };

    # users.users.${cfg.user} = {
    #   inherit (cfg) group;

    #   isSystemUser = true;
    # };
  };
}
