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

  cfg = config.hellebore.server.mariadb;

  servicesRequiringMariadb = {
    servas = config.hellebore.server.servas.enable;
  };
in {
  options.hellebore.server.mariadb = {
    enable = mkEnableOption "Hellebore's MariaDB configuration";

    package = mkPackageOption pkgs "mariadb" {};
  };

  config = mkIf cfg.enable {
    services.mysql = {
      inherit (cfg) package enable;

      ensureDatabases = mapAttrsToList (name: value: name) servicesRequiringMariadb;

      ensureUsers =
        mapAttrsToList (name: value: {
          inherit name;
          ensurePermissions = {
            "${name}.*" = "ALL PRIVILEGES";
          };
        })
        servicesRequiringMariadb;

      settings = {
        port = 3306;
        # listen_addresses = mkForce (concatStringsSep "," [
        #   "localhost"
        #   "10.88.0.1" # Podman bridge
        # ]);
      };
    };
  };
}
