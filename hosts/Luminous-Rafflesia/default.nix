{
  lib,
  config,
  ...
}: {
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

  users.extraUsers.raphiel.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjUrrPSGJtAmf57wGDbaMos00GgQYcfZ6+hVYKAkEah virgil.ribeyre@ethereal-edelweiss.cloud"
  ];

  hellebore = {
    font.size = 12;

    theme.name = "catppuccin-macchiato";

    monitors = [
      {
        name = "DP-1";
        width = 2560;
        height = 1440;
        refreshRate = 164.84;
        xOffset = 0;
        yOffset = 0;
        scaling = 1.0;
      }
      {
        name = "HDMI-A-1";
        width = 2560;
        height = 1440;
        refreshRate = 164.84;
        xOffset = 0;
        yOffset = 0;
        scaling = 1.0;
        extraArgs = [
          "mirror"
          (builtins.elemAt config.hellebore.monitors 0).name
        ];
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
      cartridges.enable = true;

      gamescope = {
        enable = true;
        capSysNice = true;
      };

      heroic-launcher.enable = true;
      lutris.enable = true;

      minecraft = {
        enable = true;
        mods.enable = true;
      };

      steam.enable = true;
      umu.enable = true;
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

      soundSharing = {
        enable = true;
        mode = "sender";
        receiverAddress = "192.168.1.150";
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

    server = {
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
