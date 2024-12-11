{lib, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Optimize Nix Store storage consumption
  nix.settings.auto-optimise-store = true;

  # Run Nix garbage collector every week
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  boot = {
    # kernelPackages = unstable-pkgs.linuxPackages_zen;
  };

  hellebore = {
    font.size = 12;

    theme.name = "catppuccin-macchiato";

    monitors = [
      {
        name = "DP-1";
        width = 2560;
        height = 1440;
        refreshRate = 165.0;
        xOffset = 0;
        yOffset = 0;
        scaling = 1.0;
      }
    ];

    network = {
      enable = true;
      enableNetworkManager = true;
      interfaces = [
        "enp6s0"
      ];
    };

    games = {
      minecraft = {
        enable = true;
        mods.enable = true;
      };

      steam.enable = true;
      gamescope = {
        enable = true;
        capSysNice = true;
      };
      lutris.enable = true;
      umu.enable = true;
      heroic-launcher.enable = true;
      wine.enable = true;
    };

    development = {
      enable = true;
      enableDocumentation = true;
    };

    power-profiles.enable = true;

    hardware = {
      amd.enable = true;

      ntfs.enable = true;

      bluetooth.enable = true;

      gaming = {
        enable = true;
        steam.enable = true;
        logitech.wireless.enable = true;
      };
    };

    bootloader = {
      enable = true;
      efiSupport = true;
      theme.screen = "2k";
    };

    fonts.enable = true;

    tools = {
      enable = true;
    };

    shell.enable = true;

    locale.enable = true;

    sound = {
      enable = true;
      lowLatency = {
        enable = true;
        rate = 48000;
        quantum = 32;
        minQuantum = 32;
        maxQuantum = 32;
      };
    };

    graphics.enable = true;

    hyprland = {
      enable = true;
      enableHyprlockPam = true;
    };

    display-manager = {
      enable = true;
      background.path = lib.cleanSource ../../assets/images/sddm/greeter.png;
    };

    ssh = {
      enable = true;
      ports = [4243];
    };

    hellebore.server = {
      fail2ban = {
        enable = true;
        maxretry = 3;
        extraIgnoreIP = [
          "109.190.182.100/32"
        ];
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
  system.stateVersion = "24.11"; # Did you read the comment?
}
