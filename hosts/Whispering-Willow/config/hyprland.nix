{ config, pkgs, lib, theme, ... }:

let
  cage-command = pkgs.writeScript "cage-command" ''
    #!${pkgs.bash}/bin/bash

    export XKB_DEFAULT_LAYOUT="fr"
    export XKB_DEFAULT_VARIANT="oss_latin9"

    ${pkgs.dbus}/bin/dbus-run-session ${lib.getExe pkgs.cage} -s -- ${greeter-command}
  '';

  greeter-command = pkgs.writeScript "greeter-command" ''
      exec ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY
      ${lib.getExe pkgs.greetd.regreet}
  '';
in
{
  environment.systemPackages = theme.gtk-theme.packages;

  # Swayosd udev rules
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
  '';

  services.greetd = {
    enable = true;
    vt = 2;
    settings.default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd zsh 2> /tmp/tuigreet.log";
    };
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd = {
    enableGnomeKeyring = true;
  };

  security.pam.services.swaylock.text = ''
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

  programs.regreet = {
    enable = true;
    settings = {
      inherit (theme.regreet-theme.regreet.settings) GTK background;

      commands = {
        # The command used to reboot the system
        reboot = [ "systemctl" "reboot" ];

        # The command used to shut down the system
        poweroff = [ "systemctl" "poweroff" ];
      };

      env = {
        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_DESKTOP = "Hyprland";
        XDG_SESSION_TYPE = "wayland";
      };
    };
  };

  programs.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
      hidpi = true;
    };
  };
}

