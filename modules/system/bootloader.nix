{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hellebore.bootloader;
in {
  options.hellebore.bootloader = {
    enable = mkEnableOption "Hellebore bootloader configuration";

    efiSupport = mkEnableOption "EFI support for the bootloader";
  };

  config = mkIf cfg.enable {
    boot.loader = {
      efi.canTouchEfiVariables = cfg.efiSupport;
      grub = {
        enable = true;
        inherit (cfg) efiSupport;
        # efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
        useOSProber = true;
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
  };
}
