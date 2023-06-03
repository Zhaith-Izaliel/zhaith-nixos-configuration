# Enable the GNOME Desktop Environment.
{ config, pkgs, ... }:

{
  # XServer
  services.xserver = {
    enable = true;

    layout = "fr";

    libinput.enable = true;

    displayManager.gdm = {
      enable = true;
      wayland = true;
    };

    # Gnome
    desktopManager.gnome = {
      enable = true;
      extraGSettingsOverrides = ''
        [org.gnome.mutter]
        experimental-features=['scale-monitor-framebuffer']
      '';
      extraGSettingsOverridePackages = [ pkgs.gnome.mutter ];
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
    gnome.cheese
  ];

  environment.systemPackages = with pkgs; [
    gnome.gnome-color-manager
    gnome.gnome-tweaks
    cinnamon.nemo
    gnome.simple-scan
    (pkgs.catppuccin-gtk.override {
      accents = [ "blue" "flamingo" "green" "lavender" "maroon" "mauve" "peach"
      "pink" "red" "rosewater" "sapphire" "sky" "teal" "yellow" ];
      size = "standard";
      variant = "macchiato";
    })
    catppuccin-cursors.macchiatoDark
    papirus-icon-theme
    gnomeExtensions.appindicator
    gnomeExtensions.espresso
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.color-picker
    gnomeExtensions.customize-ibus
    gnomeExtensions.just-perfection
    gnomeExtensions.places-status-indicator
    gnomeExtensions.workspace-indicator
  ];
}

