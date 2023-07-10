# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    # -------------------------------------------------------------------------- #
    #                                Custom Config                               #
    # -------------------------------------------------------------------------- #
    # --------------------------------- Config --------------------------------- #
    ./config/base.nix
    ./config/bootloader.nix
    ./config/development.nix
    ./config/fonts.nix
    ./config/graphics.nix
    ./config/hardware.nix
    ./config/hyprland.nix
    ./config/kernel.nix
    ./config/locale.nix
    ./config/networking.nix
    ./config/power.nix
    ./config/shell.nix
    ./config/sound.nix
    ./config/ssh.nix
    ./config/tex.nix
    ./config/tools.nix
    ./config/vm.nix
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

