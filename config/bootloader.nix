# Boot loader config
{ config, pkgs, ... }:

{
  # Use efi grub
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      efiSupport = true;
      theme = "/etc/nixos/assets/grub-theme/vimix";
      #efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
      device = "nodev";
      copyKernels = true;
      extraEntries = ''
        menuentry "Reboot" --class restart {
          reboot
        }
        menuentry "Poweroff" --class shutdown {
          halt
        }
      '';
      entryOptions = "--class nixos --unrestricted";
      subEntryOptions = "--class recovery";
    };
  };
}