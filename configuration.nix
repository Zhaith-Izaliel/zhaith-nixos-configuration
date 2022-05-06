# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # -------------------------------------------------------------------------- #
    #                                Custom Config                               #
    # -------------------------------------------------------------------------- #
    # --------------------------------- Config --------------------------------- #
    ./config/art.nix
    ./config/base.nix
    ./config/bootloader.nix
    ./config/browser.nix
    ./config/chat.nix
    ./config/development.nix
    ./config/ecryptfs.nix
    ./config/fonts.nix
    ./config/gnome.nix
    ./config/kernel.nix
    ./config/locale.nix
    ./config/multimedia.nix
    ./config/networking.nix
    ./config/office.nix
    ./config/printing.nix
    ./config/productivity.nix
    ./config/reMarkable.nix
    ./config/shell.nix
    ./config/sound.nix
    ./config/ssh.nix
    ./config/tex.nix
    ./config/tools.nix
    ./config/unity.nix
    ./config/users.nix
    ./config/vpn.nix

    # ----------------------------- Custom Scripts ----------------------------- #
    ./assets/scripts/scripts.nix

    # -------------------------------------------------------------------------- #
    #                              Switchable Config                             #
    # -------------------------------------------------------------------------- #

    # ----------------------------------- VM ----------------------------------- #
    ./config/switchable/vm/graphics.nix
    ./config/switchable/vm/kernel.nix
    ./config/switchable/vm/vm.nix

    # --------------------------------- NVidia --------------------------------- #
    #./config/switchable/nvidia/graphics.nix
    #./config/switchable/nvidia/kernel.nix
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}

