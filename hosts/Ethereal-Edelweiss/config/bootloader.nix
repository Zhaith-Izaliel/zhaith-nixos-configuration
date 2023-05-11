# Boot loader config
{ config, pkgs, ... }:

{
  # Use efi systemd-boot
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = false;
    grub = {
      enable = true;
      efiSupport = true;
      theme = "/etc/nixos/assets/grub-theme/vimix";
      #efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
      device = "nodev";
    };
  };
}