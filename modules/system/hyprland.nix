{ config, lib, pkgs, theme, ... }:

with lib;

let
  cfg = config.hellebore.hyprland;
  isNvidia =
    elem "nvidia" config.services.xserver.videoDrivers
    && config.hardware.nvidia.prime.offload.enable
      || config.hardware.nvidia.prime.reverseSync.enable;
in
{
  options.hellebore.hyprland = {
    enable = mkEnableOption "Hellebore Hyprland configuration";

    enableSwaylockPam = mkEnableOption "Swaylock PAM configuration";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gtk3
    ] ++ theme.gtk.packages;

    qt.enable = true;

    qt.platformTheme = "gtk2";

    qt.style = "gtk2";

    services.gvfs.enable = true;

    services.gnome.gnome-keyring.enable = true;

    services.gnome.gnome-settings-daemon.enable = true;

    programs.dconf.enable = true;

    security.pam.services.swaylock.text = strings.optionalString cfg.enableSwaylockPam ''
    # PAM configuration file for the swaylock screen locker. By default, it includes
    # the 'login' configuration file (see /etc/pam.d/login)
    auth include login
    '';

    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    boot.extraModprobeConfig = ''
      blacklist nouveau
      options nouveau modeset=0
    '';


    programs.hyprland = {
      enable = true;
      xwayland = {
        enable = true;
      };
      enableNvidiaPatches = isNvidia;
    };
  };
}

