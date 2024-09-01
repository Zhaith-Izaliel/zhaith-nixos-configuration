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

    radicale = enableSecret "radicale" {
      file = ./apps/radicale.age;
      owner = "radicale";
      group = "radicale";
    };

    "mail-accounts/virgil-ribeyre-at-ethereal-edelweiss-cloud" = enableSecret "mail" {
      file = ./mail-accounts/virgil-ribeyre-at-ethereal-edelweiss-cloud.age;
      owner = config.hellebore.server.mail.user;
      group = config.hellebore.server.mail.group;
    };

    ghost = enableSecret "ghost" {
      file = ./apps/ghost.age;
    };

    "outline/client-secret" = enableSecret "outline" {
      file = ./apps/outline-client-secret.age;
    };

    "authelia/redis-server-password" = enableSecret "authelia" {
      file = ./apps/authelia/redis-server-password.age;
    };

    "authelia/jwt-token" = enableSecret "authelia" {
      file = ./apps/authelia/jwt-token.age;
    };

    "authelia/storage-encryption-key" = enableSecret "authelia" {
      file = ./apps/authelia/storage-encryption-key.age;
    };

    "authelia/session-secret" = enableSecret "authelia" {
      file = ./apps/authelia/session-secret.age;
    };

    "authelia/user-database" = enableSecret "authelia" {
      file = ./apps/authelia/user-database.age;
    };
  };
}
