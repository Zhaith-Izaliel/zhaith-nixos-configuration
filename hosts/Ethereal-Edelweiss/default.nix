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
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE72R8aIght+Ci0DjXvXJ4l1UZ2f7/phFHc5gfqJ16E4 virgil.ribeyre@protonmail.com"
  ];

  hellebore = {
    font.size = 12;

    theme.name = "catppuccin-macchiato";

    server = {
      podman.enable = true;

      acme = {
        enable = true;
        email = "virgil.ribeyre@protonmail.com";
      };

      postgresql = {
        enable = true;
        package = pkgs.postgresql_15;
      };

      mariadb = {
        enable = true;
      };

      nginx.enable = true;

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
          emailPasswordFile = config.age.secrets."authelia/email-password".path;
        };
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
      };

      homarr = {
        enable = true;

        subdomain = "www";

        volumes = let
          rootVolume = "/mnt/datas/homarr";
        in {
          data = "${rootVolume}/data";
          configs = "${rootVolume}/configs";
          icons = "${rootVolume}/icons";
        };

        monitoring = {
          enable = true;
          volume = "/mnt/datas/homarr/dashdot";
        };

        redirectMainDomainToHomarr = true;
        redirectUndefinedSubdomainsToHomarr = true;

        podmanIntegration = true;

        authentication.OIDC = {
          enable = true;
          clientSecretFile = config.age.secrets."homarr/client-secret".path;
          hashedClientSecret = "$pbkdf2-sha512$310000$mAOeO6UK9kaQuOf28KC4zA$DtgSi3a7LewcCcQiJXxulbWX8j8BWM08oZCGyolfM7bOJhmE.XjoZx6SLsXebsFHxpy.EYo3Utf4spDu7M9uCw";
        };
      };

      invoiceshelf = {
        enable = true;
        subdomain = "invoices";
        volume = "/mnt/datas/invoiceshelf/volume";
        secretEnvFile = config.age.secrets.invoiceshelf-env.path;
      };

      jellyfin = {
        enable = true;
        group = "nextcloud";
        subdomain = "jellyfin";
      };

      ghost = {
        # enable = true;
        subdomain = "ghost";
        volume = "/mnt/datas/ghost";
        dbPass = config.age.secrets.ghost.path;
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
        ];
        loginAccounts = {
          "virgil.ribeyre@ethereal-edelweiss.cloud" = {
            hashedPasswordFile = config.age.secrets."mail-accounts/virgil-ribeyre-at-ethereal-edelweiss-cloud".path;
            aliases = ["postmaster@ethereal-edelweiss.cloud"];
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
        subdomain = "factorio";
        package = unstable-pkgs.factorio-headless;
        admins = [
          "Zhaith-Izaliel"
          "savaleinart"
        ];
        extraSettingsFile = config.age.secrets.factorio.path;
        game-name = "Modded Maxime-Virgil";
      };

      fail2ban = {
        enable = true;
        maxretry = 3;
      };

      virgilribeyre-com.enable = true;

      inadyn = let
        inherit (config.networking) domain;
        domains = [
          domain
          config.hellebore.server.nextcloud.domain
          config.hellebore.server.calibre-web.domain
          config.hellebore.server.jellyfin.domain
          config.hellebore.server.invoiceshelf.domain
          config.hellebore.server.radicale.domain
          config.hellebore.server.mail.domain
          config.hellebore.server.ghost.domain
          config.hellebore.server.outline.domain
          config.hellebore.server.authelia.domain
          config.hellebore.server.homarr.domain
        ];
      in {
        enable = true;
        settings = ''
          period          = 300
          verify-address  = true

          provider default@ovh.com {
            ssl         = true
            username    = ${domain}-zhaith
            password    = "@password_placeholder@"
            hostname    = { ${lib.concatStringsSep ", " domains} }
          }

          provider default@ovh.com {
            ssl = true
            username = virgilribeyre.com-zhaith
            password = "@password_placeholder@"
            hostname = { virgilribeyre.com }
          }
        '';

        passwords = {
          "@password_placeholder@" = config.age.secrets.inadyn.path;
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
      openssh = {
        enable = true;
        ports = [4242];
      };
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
