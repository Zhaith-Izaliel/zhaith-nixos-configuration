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
    ;

  cfg = config.hellebore.server.postgresql;

  servicesRequiringPostgresql = {
    nextcloud = config.hellebore.server.nextcloud.enable;
    invoiceshelf = config.hellebore.server.invoiceshelf.enable;
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
    };
  };
}
