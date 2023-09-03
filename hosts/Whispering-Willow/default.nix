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
    "nodejs-14.21.3"
  ];

  hellebore = {
    network = {
      enable = true;
      enableNetworkManager = true;
      interfaces = [
        "enp46s0"
        "wlp47s0"
      ];
    };

    hardware = {
      bluetooth = {
        enable = true;
        enablePowerSupport = true;
      };

      numerization.enable = true;

      printing = {
        enable = true;
        drivers = with pkgs; [ epson-escpr epson-escpr2 ];
      };

      # integratedCamera = {
      #   disable = true;
      #   cameraBus = "3-13";
      # };
    };

    bootloader = {
      enable = true;
      efiSupport = true;
    };

    fonts.enable = true;

    tools.enable = true;

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
      enable = true;

      cpuIsolation = {
        totalCores = "0-15";
        hostCores = "0-3,8-11";
        variableName = "ISOLATE_CPUS";
      };

      vmName = "Luminous-Rafflesia";

      pcis = [
        "0000:01:00.0"
        "0000:01:00.1"
      ];

      username = "zhaith";
    };

    sound.enable = true;

    opengl.enable = true;

    hyprland = {
      enable = true;
      enableSwaylockPam = true;
    };

    display-manager = {
      enable = true;
    };

    power-management = {
      enable = true;
      cronTemplate = "0 2 * * *";
      shutdownDate = "+60";
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

