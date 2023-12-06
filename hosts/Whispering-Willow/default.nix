# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{
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

  nixpkgs.config.permittedInsecurePackages = [
    "electron-12.2.3" # Etcher
    "electron-19.1.9" # TODO: Needs to fine which package depends on it
  ];

  hellebore = {
    fontSize = 14;

    monitors = [
      {
        name = "eDP-1";
        width = 2560;
        height = 1440;
        refreshRate = 165;
        xOffset = 0;
        yOffset = 0;
        scaling = 1.0;
      }
    ];

    network = {
      enable = true;
      enableNetworkManager = true;
      interfaces = [
        "enp46s0"
        "wlp47s0"
      ];
    };

    games = {
      enable = true;
      minecraft.enable = true;
    };

    hardware = {
      nvidia = {
        enable = true;
        power-profiles.enable = true;
        deviceFilterName = "RTX 3060";
        prime = {
          enable = true;
          offload.enable = true;
          reverseSync.enable = true;
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };
      };

      ntfs.enable = true;

      bluetooth = {
        enable = true;
        enablePowerSupport = true;
      };

      numerization.enable = true;

      printing = {
        enable = true;
        drivers = with pkgs; [ epson-escpr epson-escpr2 ];
      };

      integratedCamera = {
        disable = true;
        cameraBus = "3-13";
      };

      graphics-tablet = {
        enable = true;
        isWacom = true;
      };

      logitech = {
        enable = true;
        wireless.enable = true;
      };

      gaming.enable = true;
    };

    bootloader = {
      enable = true;
      efiSupport = true;
    };

    fonts.enable = true;

    tools = {
      enable = true;
      # etcher.enable = true;
    };

    shell.enable = true;

    kernel.enable = true;

    locale.enable = true;

    development = {
      enable = true;
      enableDocker = true;
      enableDocumentation = true;
    };

    ssh.enable = true;

    tex.enable = true;

    vm = {
      enable = false;

      cpuIsolation = {
        totalCores = "0-15";
        hostCores = "0-3,8-11";
        variableName = "ISOLATE_CPUS";
      };

      name = "Luminous-Rafflesia";

      pcisBinding = {
        enableDynamicBinding = false;
        pcis = [
          "0000:01:00.0"
          "0000:01:00.1"
        ];
      };

      username = "zhaith";
    };

    sound = {
      enable = true;
      lowLatency = {
        enable = true;
        rate = 48000;
        quantum = 64;
        minQuantum = 64;
        maxQuantum = 64;
      };
    };

    opengl.enable = true;

    hyprland = {
      enable = true;
      enableSwaylockPam = true;
    };

    display-manager = {
      enable = true;
      background.path = ../../assets/images/sddm/greeter.png;
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
  system.stateVersion = "23.05"; # Did you read the comment?
}

