{
  config,
  lib,
  pkgs,
  extra-types,
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
  options.hellebore.server.couchdb =
    {
      passwordFile = mkOption {
        default = "";
        type = types.path;
        description = "The ini file containing the admins for couchdb, alongside their password. Should be encrypted with agenix.";
      };
    }
    // extra-types.server-app {
      name = "Couchdb";
      package = "couchdb3";
      group = "couchdb";
      user = "couchdb";
      port = 5984;
    };

  config = mkIf cfg.enable {
    services.couchdb = {
      inherit (cfg) package port user group;
      enable = true;

      configFile = cfg.passwordFile;
    };
  };
}
