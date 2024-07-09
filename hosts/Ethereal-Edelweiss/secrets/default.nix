{config, ...}: {
  age.secrets = {
    factorio.file = ./apps/factorio.age;

    invoiceshelf-env.file = ./apps/invoiceshelf-env.age;

    servas-env.file = ./apps/servas-env.age;

    inadyn.file = ./services/inadyn.age;

    cozy-env.file = ./apps/cozy-env.age;

    radicale = {
      file = ./apps/radicale.age;
      owner = "radicale";
      group = "radicale";
    };

    couchdb = {
      file = ./services/couchdb.age;
      owner = config.services.couchdb.user;
      group = config.services.couchdb.group;
    };

    "mail-accounts/virgil-ribeyre-at-ethereal-edelweiss-cloud" = {
      file = ./mail-accounts/virgil-ribeyre-at-ethereal-edelweiss-cloud.age;
    };
  };
}
