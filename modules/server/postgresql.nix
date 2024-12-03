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
    mkForce
    concatStringsSep
    ;

  cfg = config.hellebore.server.postgresql;
in {
  options.hellebore.server.postgresql = {
    enable = mkEnableOption "Hellebore's PostgreSQL configuration";

    package = mkPackageOption pkgs "postgresql_15" {};
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      inherit (cfg) package enable;

      settings = {
        port = 5432;

        listen_addresses = mkForce (concatStringsSep "," [
          "localhost"
          "10.88.0.1" # Podman bridge
        ]);
      };
    };
  };
}
