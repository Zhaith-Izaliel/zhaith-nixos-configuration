{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.hellebore.bootloader;
in {
  options.hellebore.bootloader = {
    enable = mkEnableOption "Hellebore bootloader configuration";

    efiSupport = mkEnableOption "EFI support for the bootloader";

    theme.screen = mkOption {
      default = "1080p";
      example = "1080p";
      type = types.enum ["1080p" "2k" "4k" "ultrawide" "ultrawide2k"];
      description = ''
        The screen resolution to use for grub2.
      '';
    };
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
        screen = cfg.theme.screen;
        footer = true;
      };
    };
  };
}
