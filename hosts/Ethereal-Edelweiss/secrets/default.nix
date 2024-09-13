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
      file = ./apps/outline/client-secret.age;
      owner = config.hellebore.server.outline.user;
      group = config.hellebore.server.authelia.group;
      mode = "770";
    };

    "homarr/client-secret" = enableSecret "homarr" {
      file = ./apps/homarr/client-secret.age;
      group = config.hellebore.server.authelia.group;
      mode = "770";
    };

    "authelia/database-password" = enableSecret "authelia" {
      file = ./apps/authelia/database-password.age;
      owner = config.hellebore.server.authelia.user;
      group = config.hellebore.server.authelia.group;
    };

    "authelia/redis-server-password" = enableSecret "authelia" {
      file = ./apps/authelia/redis-server-password.age;
      owner = config.hellebore.server.authelia.user;
      group = config.hellebore.server.authelia.group;
    };

    "authelia/jwt-token" = enableSecret "authelia" {
      file = ./apps/authelia/jwt-token.age;
      owner = config.hellebore.server.authelia.user;
      group = config.hellebore.server.authelia.group;
    };

    "authelia/storage-encryption-key" = enableSecret "authelia" {
      file = ./apps/authelia/storage-encryption-key.age;
      owner = config.hellebore.server.authelia.user;
      group = config.hellebore.server.authelia.group;
    };

    "authelia/session-secret" = enableSecret "authelia" {
      file = ./apps/authelia/session-secret.age;
      owner = config.hellebore.server.authelia.user;
      group = config.hellebore.server.authelia.group;
    };

    "authelia/hmac-secret" = enableSecret "authelia" {
      file = ./apps/authelia/hmac-secret.age;
      owner = config.hellebore.server.authelia.user;
      group = config.hellebore.server.authelia.group;
    };

    "authelia/jwk-private" = enableSecret "authelia" {
      file = ./apps/authelia/jwk-private.age;
      owner = config.hellebore.server.authelia.user;
      group = config.hellebore.server.authelia.group;
    };

    "authelia/jwk-public" = enableSecret "authelia" {
      file = ./apps/authelia/jwk-public.age;
      owner = config.hellebore.server.authelia.user;
      group = config.hellebore.server.authelia.group;
    };

    "authelia/user-database" = enableSecret "authelia" {
      file = ./apps/authelia/user-database.age;
      owner = config.hellebore.server.authelia.user;
      group = config.hellebore.server.authelia.group;
    };

    "authelia/email-password" = enableSecret "authelia" {
      file = ./apps/authelia/email-password.age;
      owner = config.hellebore.server.authelia.user;
      group = config.hellebore.server.authelia.group;
    };
  };
}
