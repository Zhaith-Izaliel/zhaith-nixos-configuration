# Enable the GNOME Desktop Environment.
{ config, pkgs, ... }:

{
  # XServer
  services.xserver = {
    enable = true;

    layout = "fr";

    libinput.enable = true;

    displayManager = {
      gdm = {
        enable = true;
        wayland = false;
      };
    };

    # Gnome
    desktopManager.gnome = {
      enable = true;
    };
  };

  programs.dconf.enable = true;


  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  services.gnome = {
    core-utilities.enable = true;
    gnome-settings-daemon.enable = true;
    gnome-keyring.enable = true;
    gnome-browser-connector.enable = true;
  };

  programs.gnome-disks.enable = true;

  environment.gnome.excludePackages = with pkgs; [
    gnome.nautilus
    gnome-photos
    gnome.gnome-music
    gnome.gnome-terminal
    gnome.gedit
    epiphany
    gnome.totem
    gnome-tour
    gnome.geary
  ];

  environment.systemPackages = with pkgs; [
    gnome.gnome-color-manager
    gnome.cheese
    gnome.gnome-tweaks
    libnotify
    cinnamon.nemo
    gnome.simple-scan
  ];
}
