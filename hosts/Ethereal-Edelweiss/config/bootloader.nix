{
  config,
  pkgs,
  ...
}: {
  # Use efi systemd-boot
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = false;
    grub = {
      enable = true;
      efiSupport = true;
      #efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
      device = "nodev";
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
