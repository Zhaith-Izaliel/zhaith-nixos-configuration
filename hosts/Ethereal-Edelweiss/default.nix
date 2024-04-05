{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: let
  virgilribeyre-package = inputs.virgilribeyre-com.packages.${pkgs.system}.default;
in {
  imports = [
    ./hardware-configuration.nix
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

  services.inadyn = let
    inherit (config.networking) domain;
    domains = [
      "${config.hellebore.server.nextcloud.subdomain}.${domain}"
      "${config.hellebore.server.calibre-web.subdomain}.${domain}"
      "${config.hellebore.server.jellyfin.subdomain}.${domain}"
      "${config.hellebore.server.invoiceshelf.subdomain}.${domain}"
      domain
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
      "@password_placeholder@" = "/mnt/datas/inadyn/inadyn-password";
    };
  };

  # virgilribeyre.com
  services.nginx.virtualHosts."virgilribeyre.com" = {
    enableACME = true;
    forceSSL = true;

    serverAliases = [
      "www.virgilribeyre.com"
    ];

    locations = {
      "/" = {
        root = "${virgilribeyre-package}";
        index = "index.html";
        tryFiles = "$uri $uri/ /index.html";
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    certs = {
      "virgilribeyre.com".email = "virgil.ribeyre@protonmail.com";
    };
  };

  hellebore = {
    font.size = 12;

    theme.name = "catppuccin-macchiato";

    server = {
      postgresql = {
        enable = true;
        package = pkgs.postgresql_15;
      };

      nginx.enable = true;

      nextcloud = {
        enable = true;
        subdomain = "nextcloud";
        acmeEmail = "virgil.ribeyre@protonmail.com";
      };

      invoiceshelf = {
        enable = true;
        subdomain = "invoices";
        acmeEmail = "virgil.ribeyre@protonmail.com";
        volume = "/mnt/datas/invoiceshelf/volume";
      };

      jellyfin = {
        enable = true;
        group = "nextcloud";
        subdomain = "jellyfin";
        acmeEmail = "virgil.ribeyre@protonmail.com";
      };

      calibre-web = {
        enable = true;
        group = "nextcloud";
        library = "/mnt/datas/nextcloud/data/Zhaith/files/Books";
        subdomain = "books";
        acmeEmail = "virgil.ribeyre@protonmail.com";
      };

      fail2ban = {
        enable = true;
        maxretry = 3;
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

    development.enable = true;

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
  system.stateVersion = "21.05"; # Did you read the comment?
}
