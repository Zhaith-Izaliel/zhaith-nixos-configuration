{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.hellebore.server;
  enableSecret = service: attrs: mkIf cfg.${service}.enable attrs;
in {
  age.secrets = {
    factorio = enableSecret "factorio" {
      file = ./apps/factorio.age;
    };

    invoiceshelf-env = enableSecret "invoiceshelf" {
      file = ./apps/invoiceshelf-env.age;
    };

    servas-env = enableSecret "servas" {
      file = ./apps/servas-env.age;
    };

    inadyn = enableSecret "inadyn" {
      file = ./services/inadyn.age;
    };

    cozy-env = enableSecret "cozy" {
      file = ./apps/cozy-env.age;
    };

    radicale = enableSecret "radicale" {
      file = ./apps/radicale.age;
      owner = "radicale";
      group = "radicale";
    };

    couchdb = enableSecret "couchdb" {
      file = ./services/couchdb.age;
      owner = config.services.couchdb.user;
      group = config.services.couchdb.group;
    };

    # "mail-accounts/virgil-ribeyre-at-ethereal-edelweiss-cloud" = {
    #   file = ./mail-accounts/virgil-ribeyre-at-ethereal-edelweiss-cloud.age;
    #   owner = config.mailserver.vmailUserName;
    #   group = config.mailserver.vmailGroupName;
    # };
  };
}
