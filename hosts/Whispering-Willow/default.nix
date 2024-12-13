{
  pkgs,
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

  services.teamviewer.enable = true;

  hellebore = {
    font.size = 10;

    theme.name = "catppuccin-macchiato";

    monitors = [
      {
        name = "eDP-1";
        width = 1920;
        height = 1200;
        refreshRate = 60.0;
        xOffset = 0;
        yOffset = 0;
        scaling = 1.0;
      }
      {
        name = "DP-1";
        width = 2560;
        height = 1440;
        refreshRate = 59.95;
        xOffset = 0;
        yOffset = 0;
        scaling = 1.0;
        extraArgs = [
          "mirror"
          (builtins.elemAt config.hellebore.monitors 0).name
        ];
      }
      {
        name = "HDMI-A-1";
        width = 1920;
        height = 1080;
        refreshRate = 60.0;
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
        "wlp2s0"
      ];
    };

    games = {
      minecraft = {
        enable = true;
        mods.enable = true;
      };

      moonlight.enable = true;
      steam.enable = true;
      wine.enable = true;
    };

    power-profiles.enable = true;

    hardware = {
      amd.enable = true;

      ntfs.enable = true;

      bluetooth.enable = true;

      printing = {
        enable = true;
        numerization.enable = true;
        drivers = with pkgs; [
          epson-escpr
          epson-escpr2
        ];
      };

      integratedCamera = {
        disable = true;
        cameraBus = "3-1";
      };

      gaming = {
        enable = true;
        steam.enable = true;
        logitech.wireless.enable = true;
      };
    };

    bootloader = {
      enable = true;
      efiSupport = true;
      theme.screen = "1080p";
    };

    fonts.enable = true;

    tools = {
      enable = true;
      nix-alien.enable = true;
      input-remapper.enable = true;
    };

    shell.enable = true;

    locale.enable = true;

    development = {
      enable = true;
      enablePodman = true;
      enableDocumentation = true;
    };

    tex = {
      enable = true;
      scheme = "full";
    };

    sound = {
      enable = true;
      soundSharing = {
        enable = true;
        mode = "receiver";
        multicastAddress = "224.0.0.1";
      };

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
      screenRotation.enable = true;
    };

    display-manager = {
      enable = true;
      background.path = lib.cleanSource ../../assets/images/sddm/greeter.png;
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

      upower = {
        enable = true;
        notify = false;
        percentageLow = 15;
        percentageCritical = 10;
        percentageAction = 5;
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
