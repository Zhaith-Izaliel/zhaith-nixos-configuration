{
  pkgs,
  lib,
  config,
  unstable-pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./secrets
  ];

  time.timeZone = "Europe/Paris";

  # Optimize Nix Store storage consumption
  nix.settings.auto-optimise-store = true;

  # Run Nix garbage collector every week
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  users.extraUsers.lilith.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE72R8aIght+Ci0DjXvXJ4l1UZ2f7/phFHc5gfqJ16E4 virgil.ribeyre@ethereal-edelweiss.cloud"
  ];

  hellebore = {
    font.size = 12;

    theme.name = "catppuccin-macchiato";

    server = {
      podman.enable = true;

      acme = {
        enable = true;
        email = "support@ethereal-edelweiss.cloud";
      };

      postgresql = {
        enable = true;
        package = pkgs.postgresql_15;
      };

      mariadb = {
        enable = true;
      };

      nginx.enable = true;

      enclosed = {
        enable = true;
        subdomain = "enclosed";
        volume = "/mnt/datas/enclosed/volume";
        secretEnvFile = config.age.secrets."enclosed/secret-env".path;
      };

      authelia = {
        enable = true;
        package = unstable-pkgs.authelia;
        subdomain = "auth";

        secrets = {
          databasePasswordFile = config.age.secrets."authelia/database-password".path;
          redisServerPasswordFile = config.age.secrets."authelia/redis-server-password".path;
          jwtSecretFile = config.age.secrets."authelia/jwt-token".path;
          sessionSecretFile = config.age.secrets."authelia/session-secret".path;
          oidcHmacSecretFile = config.age.secrets."authelia/hmac-secret".path;
          oidcIssuerPrivateKeyFile = config.age.secrets."authelia/jwk-private".path;
          storageEncryptionKeyFile = config.age.secrets."authelia/storage-encryption-key".path;
          userDatabase = config.age.secrets."authelia/user-database".path;
        };

        mail = {
          username = "noreply";
          mail = "noreply@auth.ethereal-edelweiss.cloud";
          passwordFile = config.age.secrets."authelia/mail-password".path;
          protocol = "submissions";
          identifier = config.mailserver.fqdn;
          host = config.mailserver.fqdn;
          port = 465;
        };
      };

      vaultwarden = {
        enable = true;
        subdomain = "vaultwarden";
        registration.domainsWhitelist = [config.networking.domain];
        secretEnvFile = config.age.secrets."vaultwarden/secret-env".path;

        mail = {
          username = "noreply";
          mail = "noreply@vaultwarden.ethereal-edelweiss.cloud";
          security = "force_tls";
          host = config.mailserver.fqdn;
          port = 465;
        };

        # backupDir = "/mnt/datas/vaultwarden.bak";
      };

      nextcloud = {
        enable = true;
        subdomain = "nextcloud";
      };

      outline = {
        enable = true;
        subdomain = "outline";
        storagePath = "/mnt/datas/outline/data";

        authentication.OIDC = {
          clientSecretFile = config.age.secrets."outline/client-secret".path;
          hashedClientSecret = "$pbkdf2-sha512$310000$EZbHn.dy0T9tDJz8/U6Ogw$XZk2VV9cbTrWqo0VWHPA4sfSV3bZgWmElebm7FF1elnNuLvdhd6YeCJbwEcI2PjaEg2gLu/xYaZXhLd4seFcVg";
        };

        mail = {
          username = "noreply";
          mail = "noreply@outline.ethereal-edelweiss.cloud";
          passwordFile = config.age.secrets."outline/mail-password".path;
          host = config.mailserver.fqdn;
          secure = true;
          port = 465;
        };
      };

      mealie = {
        enable = false;
        subdomain = "mealie";
        secretEnvFile = config.age.secrets."mealie/secret-env".path;
        # storagePath = "/mnt/datas/mealie/data";

        authentication.OIDC = {
          hashedClientSecret = "$pbkdf2-sha512$310000$BLpApuMTaOw4nDHZWUlz2A$m8pBnPq5t0IbYF7iQm2R/X2kuM/uoYfg1IEsCJyBzFqLphYzCENcvSvifck0K6QUkrfYgjNz8rv5u8OQQjO1Pw";
        };

        mail = {
          username = "noreply";
          mail = "noreply@mealie.ethereal-edelweiss.cloud";
          host = config.mailserver.fqdn;
          encryption = "ssl";
          port = 465;
        };
      };

      invoiceshelf = {
        enable = true;
        subdomain = "invoices";
        volume = "/mnt/datas/invoiceshelf/volume";
        secretEnvFile = config.age.secrets."invoiceshelf/secret-env".path;
        mail = {
          username = "noreply";
          passwordFile = config.age.secrets."invoiceshelf/mail-password".path;
          mail = "noreply@invoices.ethereal-edelweiss.cloud";
          host = config.mailserver.fqdn;
          encryption = "ssl";
          port = 465;
        };
      };

      jellyfin = {
        enable = true;
        group = "nextcloud";
        subdomain = "jellyfin";
      };

      dashy = {
        enable = true;
        setDomainAsDefault = true;
        volume = "/mnt/datas/dashy";
        subdomain = "www";
      };

      ghost = {
        enable = true;
        subdomain = "ghost";
        volume = "/mnt/datas/ghost";
        dbPass = config.age.secrets."ghost/database-password".path;
        mail = {
          username = "support";
          passwordFile = config.age.secrets."ghost/mail-password".path;
          mail = "support@ghost.ethereal-edelweiss.cloud";
          host = config.mailserver.fqdn;
          secure = true;
          port = 465;
        };
      };

      radicale = {
        enable = true;
        storage = "/mnt/datas/radicale";
        subdomain = "radicale";
        auth.file = config.age.secrets.radicale.path;
      };

      mail = {
        enable = true;
        subdomain = "mail";
        domains = [
          "ethereal-edelweiss.cloud"
          "silvered-ivy.games"
        ];
        loginAccounts = {
          "virgil.ribeyre@ethereal-edelweiss.cloud" = {
            hashedPasswordFile = config.age.secrets."mail-accounts/virgil-ribeyre-at-ethereal-edelweiss-cloud".path;
            aliases = [
              "zhaith.izaliel@ethereal-edelweiss.cloud"
            ];
          };

          "virgil.ribeyre@silvered-ivy.games" = {
            hashedPasswordFile = config.age.secrets."mail-accounts/virgil-ribeyre-at-silvered-ivy-games".path;
          };

          "support" = {
            name = "support@ethereal-edelweiss.cloud";
            hashedPasswordFile = config.age.secrets."mail-accounts/support-at-ethereal-edelweiss-cloud".path;
            aliases = [
              "postmaster@ethereal-edelweiss.cloud"
              "abuse@ethereal-edelweiss.cloud"

              # App aliases
              "support@ghost.ethereal-edelweiss.cloud"
            ];
          };

          "noreply" = {
            name = "noreply@ethereal-edelweiss.cloud";
            hashedPasswordFile = config.age.secrets."mail-accounts/noreply-at-ethereal-edelweiss-cloud".path;
            sendOnly = true;
            aliases = [
              "noreply@auth.ethereal-edelweiss.cloud"
              "noreply@outline.ethereal-edelweiss.cloud"
              "noreply@nextcloud.ethereal-edelweiss.cloud"
              "noreply@vaultwarden.ethereal-edelweiss.cloud"
              "noreply@invoices.ethereal-edelweiss.cloud"
              "noreply@mealie.ethereal-edelweiss.cloud"
            ];
          };
        };
        mailDirectory = "/mnt/datas/mails";
      };

      calibre-web = {
        enable = true;
        group = "nextcloud";
        library = "/mnt/datas/nextcloud/data/Zhaith/files/Books";
        subdomain = "books";
      };

      factorio = {
        enable = true;
        package = unstable-pkgs.factorio-headless.overrideAttrs (final: prev: rec {
          version = "2.0.15";

          src = pkgs.fetchurl {
            url = "https://factorio.com/get-download/${version}/headless/linux64";
            name = "factorio_headless_x64-${version}.tar.xz";
            sha256 = "1n1qlnmgn969bxkj67xx8gh7m38xihj0f4f0hq2sc4bqh35l3d3h";
          };
        });
        admins = [
          "Zhaith-Izaliel"
          "savaleinart"
          "Nelyth"
        ];
        extraSettingsFile = config.age.secrets.factorio.path;
        game-name = "Cracktorio: Space Age";
      };

      fail2ban = {
        enable = true;
        maxretry = 3;
        extraIgnoreIP = [
          "109.190.182.100/32"
        ];
      };

      virgilribeyre-com.enable = true;

      inadyn = let
        inherit (config.networking) domain;
        domains = [
          domain
          config.hellebore.server.authelia.domain
          config.hellebore.server.calibre-web.domain
          config.hellebore.server.dashy.domain
          config.hellebore.server.enclosed.domain
          config.hellebore.server.ghost.domain
          config.hellebore.server.invoiceshelf.domain
          config.hellebore.server.jellyfin.domain
          config.hellebore.server.mail.domain
          config.hellebore.server.mealie.domain
          config.hellebore.server.nextcloud.domain
          config.hellebore.server.outline.domain
          config.hellebore.server.radicale.domain
          config.hellebore.server.vaultwarden.domain
        ];
      in {
        enable = true;
        settings = ''
          period          = 300
          verify-address  = true

          provider default@ovh.com {
            ssl         = true
            username    = ${domain}-zhaith
            password    = "@ethereal_edelweiss_pass_placeholder@"
            hostname    = { ${lib.concatStringsSep ", " domains} }
          }

          provider default@ovh.com {
            ssl = true
            username = virgilribeyre.com-zhaith
            password = "@virgilribeyre_pass_placeholder@"
            hostname = { virgilribeyre.com, www.virgilribeyre.com }
          }

          provider default@ovh.com {
            ssl = true
            username = silvered-ivy.games-zhaith
            password = "@silvered_ivy_pass_placeholder@"
            hostname = { silvered-ivy.games }
          }
        '';

        passwords = {
          "@ethereal_edelweiss_pass_placeholder@" = config.age.secrets."inadyn/ethereal-edelweiss".path;
          "@virgilribeyre_pass_placeholder@" = config.age.secrets."inadyn/virgilribeyre".path;
          "@silvered_ivy_pass_placeholder@" = config.age.secrets."inadyn/silvered-ivy".path;
        };
      };
    };

    network = {
      enable = true;
      domain = "ethereal-edelweiss.cloud";
      interfaces = [
        "enp4s0"
        "wlp3s0"
      ];

      allowedTCPPorts = [
        80
        25
        443
      ];
    };

    hardware.ntfs.enable = true;

    bootloader = {
      enable = true;
      efiSupport = true;
    };

    fonts.enable = true;

    tools.enable = true;

    shell.enable = true;

    locale.enable = true;

    development = {
      enable = true;
    };

    ssh = {
      enable = true;
      ports = [4242];
    };

    power-management = {
      enable = true;
      autoShutdown = {
        enable = true;
        cronTemplate = "0 2 * * *";
        shutdownDate = "+60";
        reminders = [
          "50 2 * * *"
        ];
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
