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
    mkIf
    ;

  cfg = config.hellebore.server.mariadb;
in {
  options.hellebore.server.mariadb = {
    enable = mkEnableOption "Hellebore's MariaDB configuration";

    package = mkPackageOption pkgs "mariadb" {};
  };

  config = mkIf cfg.enable {
    services.mysql = {
      inherit (cfg) package enable;

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
