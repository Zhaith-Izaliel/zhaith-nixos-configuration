{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkPackageOption
    mapAttrsToList
    mkIf
    mkForce
    concatStringsSep
    ;

  cfg = config.hellebore.server.postgresql;

  servicesRequiringPostgresql = {
    nextcloud = config.hellebore.server.nextcloud.enable;
    invoiceshelf = config.hellebore.server.invoiceshelf.enable;
    twentycrm = config.hellebore.server.twentycrm.enable;
  };
in {
  options.hellebore.server.postgresql = {
    enable = mkEnableOption "Hellebore's PostgreSQL configuration";

    package = mkPackageOption pkgs "postgresql_15" {};
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      inherit (cfg) package enable;

      ensureDatabases = mapAttrsToList (name: value: name) servicesRequiringPostgresql;

      ensureUsers =
        mapAttrsToList (name: value: {
          inherit name;
          ensureDBOwnership = true;
        })
        servicesRequiringPostgresql;

      settings = {
        listen_addresses = mkForce (concatStringsSep "," [
          "localhost"
          "10.88.0.1" # Podman bridge
        ]);
      };
    };
  };
}
