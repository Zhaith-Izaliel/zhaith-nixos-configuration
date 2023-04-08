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
  };

  programs.dconf.enable = true;

  # Gnome
  services.xserver.desktopManager.gnome = {
    enable = true;
  };

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
    gnome.cheese
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
    gnome.gnome-tweaks
    libnotify
    papirus-icon-theme
    cinnamon.nemo
    gnome.simple-scan
    nordzy-cursor-theme
    nordic
  ];
}