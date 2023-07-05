{ ... }:

{
  # Use efi grub
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      efiSupport = true;
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

    grub2-theme = {
      enable = true;
      theme = "tela";
      icon = "color";
      screen = "1080p";
      footer = true;
    };
  };
}

