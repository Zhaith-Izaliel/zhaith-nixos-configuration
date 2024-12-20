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
      owner = config.hellebore.server.factorio.user;
      group = config.hellebore.server.factorio.group;
    };

    "invoiceshelf/secret-env" = enableSecret "invoiceshelf" {
      file = ./apps/invoiceshelf/secret-env.age;
    };

    "invoiceshelf/mail-password" = enableSecret "invoiceshelf" {
      file = ./apps/invoiceshelf/mail-password.age;
    };

    "enclosed/secret-env" = enableSecret "enclosed" {
      file = ./apps/enclosed/secret-env.age;
    };

    "mealie/secret-env" = enableSecret "mealie" {
      file = ./apps/mealie/secret-env.age;
      owner = config.hellebore.server.mealie.user;
      group = config.hellebore.server.mealie.group;
    };

    "inadyn/silvered-ivy" = enableSecret "inadyn" {
      file = ./services/inadyn/silvered-ivy.age;
      owner = config.hellebore.server.inadyn.user;
      group = config.hellebore.server.inadyn.group;
    };

    "inadyn/virgilribeyre" = enableSecret "inadyn" {
      file = ./services/inadyn/virgilribeyre.age;
      owner = config.hellebore.server.inadyn.user;
      group = config.hellebore.server.inadyn.group;
    };

    "inadyn/ethereal-edelweiss" = enableSecret "inadyn" {
      file = ./services/inadyn/ethereal-edelweiss.age;
      owner = config.hellebore.server.inadyn.user;
      group = config.hellebore.server.inadyn.group;
    };

    radicale = enableSecret "radicale" {
      file = ./apps/radicale.age;
      owner = "radicale";
      group = "radicale";
    };

    "vaultwarden/secret-env" = enableSecret "vaultwarden" {
      file = ./apps/vaultwarden/secret-env.age;
      owner = "vaultwarden";
      group = "vaultwarden";
    };

    "mail-accounts/virgil-ribeyre-at-ethereal-edelweiss-cloud" = enableSecret "mail" {
      file = ./mail-accounts/virgil-ribeyre-at-ethereal-edelweiss-cloud.age;
      owner = config.hellebore.server.mail.user;
      group = config.hellebore.server.mail.group;
    };

    "mail-accounts/virgil-ribeyre-at-silvered-ivy-games" = enableSecret "mail" {
      file = ./mail-accounts/virgil-ribeyre-at-silvered-ivy-games.age;
      owner = config.hellebore.server.mail.user;
      group = config.hellebore.server.mail.group;
    };

    "mail-accounts/noreply-at-ethereal-edelweiss-cloud" = enableSecret "mail" {
      file = ./mail-accounts/noreply-at-ethereal-edelweiss-cloud.age;
      owner = config.hellebore.server.mail.user;
      group = config.hellebore.server.mail.group;
    };

    "mail-accounts/support-at-ethereal-edelweiss-cloud" = enableSecret "mail" {
      file = ./mail-accounts/support-at-ethereal-edelweiss-cloud.age;
      owner = config.hellebore.server.mail.user;
      group = config.hellebore.server.mail.group;
    };

    "ghost/mail-password" = enableSecret "ghost" {
      file = ./apps/ghost/mail-password.age;
      # owner = config.hellebore.server.ghost.user;
      # group = config.hellebore.server.ghost.group;
    };

    "ghost/database-password" = enableSecret "ghost" {
      file = ./apps/ghost/database-password.age;
      # owner = config.hellebore.server.ghost.user;
      # group = config.hellebore.server.ghost.group;
    };

    "outline/client-secret" = enableSecret "outline" {
      file = ./apps/outline/client-secret.age;
      owner = config.hellebore.server.outline.user;
      group = config.hellebore.server.authelia.group;
      mode = "770";
    };

    "outline/mail-password" = enableSecret "outline" {
      file = ./apps/outline/client-secret.age;
      owner = config.hellebore.server.outline.user;
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

    "authelia/mail-password" = enableSecret "authelia" {
      file = ./apps/authelia/mail-password.age;
      owner = config.hellebore.server.authelia.user;
      group = config.hellebore.server.authelia.group;
    };
  };
}
