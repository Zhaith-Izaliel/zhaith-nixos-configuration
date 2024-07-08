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
    mkOption
    mkIf
    types
    ;

  cfg = config.hellebore.server.couchdb;
in {
  options.hellebore.server.couchdb = {
    enable = mkEnableOption "Hellebore's couchdb configuration";

    package = mkPackageOption pkgs "couchdb3" {};

    passwordFile = mkOption {
      default = "";
      type = types.path;
      description = "The ini file containing the admins for couchdb, alongside their password. Should be encrypted with agenix.";
    };
  };

  config = mkIf cfg.enable {
    services.couchdb = {
      inherit (cfg) package enable;

      configFile = cfg.passwordFile;
    };
  };
}
