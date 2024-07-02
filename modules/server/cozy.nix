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
    COUCHDB_HOST = "cozy-couchdb";
    COUCHDB_PORT = toString config.services.couchdb.port;
    COUCHDB_USER = cfg.user;
    COZY_SUBDOMAIN_TYPE = cfg.subdomainType;
  };
in {
  options.hellebore.server.cozy =
    {
      volume = mkOption {
        default = "/var/lib/cozy";
        description = lib.mdDoc "Directory to store Cozy volume.";
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

      subdomainType = mkOption {
        default = "nested";
        type = types.enum ["nested" "flat"];
        description = ''
          Application subdomain type for each Cozy.
          Could be nested (https://<app>.<instance>.<domain>) or flat (https://<instance>-<app>.<domain>)
        '';
      };
    }
    // extra-types.server-app {
      name = "Cozy";
      user = "cozy";
      group = "cozy";
      database = "cozy";
      port = 8080;
    };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      cozy = {
        inherit environment;

        image = "cozy/cozy-stack";

        volumes = [
          "${cfg.volume}/data:/var/lib/cozy/data"
          "${cfg.volume}/config:/etc/cozy"
        ];

        ports = [
          "${toString cfg.port}:8080"
        ];

        environmentFiles = [
          cfg.secretEnvFile
        ];

        dependsOn = [
          "cozy-couchdb"
        ];
      };

      cozy-couchdb = {
        inherit environment;

        image = "couchdb:3.3";

        hostname = "cozy-couchdb";

        volumes = [
          "${cfg.volume}/couchdb:/opt/couchdb/data"
        ];

        environmentFiles = [
          cfg.secretEnvFile
        ];
      };
    };

    hellebore.server.nginx.enable = mkDefault true;

    services.nginx.virtualHosts."*.${domain}" = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "/" = {
          proxyPass = "http://localhost:${toString cfg.port}";
        };
      };
    };
  };
}
