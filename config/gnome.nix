# Enable the GNOME Desktop Environment.
{ config, pkgs, ... }:

let
  orchis-theme-override = pkgs.orchis-theme.override { tweaks = [
      "primary"
      "black"
    ]; };
in
{
  # GDM service
  services.xserver.displayManager = {
    gdm = {
     enable = true;
     wayland = false;
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
    (import ../assets/packages/volante-cursors)
    orchis-theme-override
  ];
}