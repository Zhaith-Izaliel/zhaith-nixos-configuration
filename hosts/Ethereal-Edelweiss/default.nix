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

      nginx.enable = true;

      nextcloud = {
        enable = true;
        subdomain = "nextcloud";
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

      couchdb = {
        enable = true;
        passwordFile = config.age.secrets.couchdb.path;
      };

      cozy = {
        enable = true;
        subdomain = "cozy";
        volume = "/mnt/datas/cozy/volume";
        installedApps = [
          "home"
          "banks"
          "contacts"
          "drive"
          "passwords"
          "photos"
          "settings"
          "store"
          "mespapiers"
        ];
        secretEnvFile = config.age.secrets.cozy-env.path;
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

      servas = {
        enable = true;
        volume = "/mnt/datas/servas/volume";
        secretEnvFile = config.age.secrets.servas-env.path;
        allowRegistration = false;
        subdomain = "bookmarks";
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
          "${config.hellebore.server.nextcloud.subdomain}.${domain}"
          "${config.hellebore.server.calibre-web.subdomain}.${domain}"
          "${config.hellebore.server.jellyfin.subdomain}.${domain}"
          "${config.hellebore.server.invoiceshelf.subdomain}.${domain}"
          "${config.hellebore.server.servas.subdomain}.${domain}"
          "${config.hellebore.server.radicale.subdomain}.${domain}"
          "${config.hellebore.server.mail.subdomain}.${domain}"
          # Cozy
          "${config.hellebore.server.cozy.subdomain}.${domain}"
          "*.${config.hellebore.server.cozy.subdomain}.${domain}"
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
