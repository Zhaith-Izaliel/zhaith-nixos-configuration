{ config, pkgs, ... }:

let
  theme = "tela";
  grub2-themes = import ../assets/packages/grub2-themes { inherit pkgs theme; };
in
{
  # Use efi grub
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      efiSupport = true;
      theme = "${grub2-themes.package}/${theme}";
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
