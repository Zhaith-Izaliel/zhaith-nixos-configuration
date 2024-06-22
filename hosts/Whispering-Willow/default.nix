{
  pkgs,
  stable-pkgs,
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

  nixpkgs.config.permittedInsecurePackages = [
    "electron-12.2.3" # Etcher
  ];

  boot = {
    kernelPackages = stable-pkgs.linuxPackages;
    # initrd.kernelModules = ["i915"];
  };

  # Find vendor and device using `udevadm info /dev/dri/cardX --attribute-walk`
  services.udev.extraRules = ''
    KERNEL=="card*", SUBSYSTEM=="drm", ATTRS{vendor}=="0x8086", ATTRS{device}=="0x9a60", SYMLINK+="dri/by-name/intel-tigerlake-h-gt1"
    KERNEL=="card*", SUBSYSTEM=="drm", ATTRS{vendor}=="0x10de", ATTRS{device}=="0x2520", SYMLINK+="dri/by-name/nvidia-geforce-rtx-3060-mobile"
  '';

  hellebore = {
    font.size = 12;

    theme.name = "catppuccin-macchiato";

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
      {
        name = "";
        width = 1920;
        height = 1080;
        refreshRate = 60;
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
        "enp46s0"
        "wlp47s0"
      ];
    };

    games = {
      enable = true;
      steam.enable = true;
      minecraft = {
        enable = true;
        mods.enable = true;
      };
      cartridges.enable = true;
      lutris.enable = true;
      gamemode.enable = true;
      gamescope.enable = true;
    };

    hardware = {
      nvidia = {
        enable = true;
        package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
        power-profiles.enable = true;
        power-management.enable = true;
        modesetting.enable = true;
        deviceFilterName = "RTX 3060";
        open = false;
        prime = {
          offload.enable = true;
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };
        # fixes = {
        #   usbCDriversWronglyLoaded = true;
        # };
      };

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
        cameraBus = "3-13";
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
      theme.screen = "2k";
    };

    fonts.enable = true;

    tools = {
      enable = true;
      nix-alien.enable = true;
    };

    shell.enable = true;

    locale.enable = true;

    development = {
      enable = true;
      enablePodman = true;
      enableDocumentation = true;
    };

    ssh.enable = true;

    tex.enable = true;

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
      enableSwaylockPam = true;
      renderingCards = {
        enable = true;
        defaultCards = [
          "/dev/dri/by-name/intel-tigerlake-h-gt1"
          # "/dev/dri/by-name/nvidia-geforce-rtx-3060-mobile"
        ];
      };
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
        notify = true;
        percentageLow = 15;
        percentageCritical = 10;
        percentageAction = 5;
      };
    };

    vm = {
      enable = false;

      useSecureBoot = true;

      cpuIsolation = {
        totalCores = "0-15";
        hostCores = "0-3,8-11";
        variableName = "ISOLATE_CPUS";
      };

      name = "Luminous-Rafflesia";

      pcisBinding = {
        enableDynamicBinding = true;
        vendorIds = [
          "10de:2520" # GPU
          "10de:228e" # Audio
        ];
      };

      username = "zhaith";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
