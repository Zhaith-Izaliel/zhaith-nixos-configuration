{ pkgs, lib, common-attrs, ... }:

let
  regreet-hyprland-config = pkgs.writeText "regreet-hyprland.conf" ''
    exec-once = ${lib.getExe pkgs.greetd.regreet}; ${pkgs.hyprland}/bin/hyprctl dispatch exit

    input {
      kb_layout = fr
      kb_variant = oss_latin9
    }
  '';
in
{
  environment.systemPackages = with pkgs; [
    seatd
  ] ++ common-attrs.gtk-theme.packages;

  # Swayosd udev rules
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
  '';

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.dbus}/bin/dbus-run-session -- ${lib.getExe pkgs.hyprland} --config ${regreet-hyprland-config}";
      user = "greeter";
    };
  };

  services.gnome.gnome-keyring.enable = true;

  security.pam.services.swaylock.text = ''
    # PAM configuration file for the swaylock screen locker. By default, it includes
    # the 'login' configuration file (see /etc/pam.d/login)
    auth include login
  '';

  programs.regreet = {
    enable = true;
    settings = {
      GTK = {
        # Whether to use the dark theme
        application_prefer_dark_theme = true;

        # Cursor theme name
        cursor_theme_name = common-attrs.gtk-theme.cursorTheme.name;

        # Font name and size
        font_name = "${common-attrs.gtk-theme.font.name} ${toString common-attrs.gtk-theme.font.size}";

        # Icon theme name
        icon_theme_name = common-attrs.gtk-theme.iconTheme.name;

        # GTK theme name
        theme_name = common-attrs.gtk-theme.theme.name;

      };

      commands = {
        # The command used to reboot the system
        reboot = [ "systemctl" "reboot" ];

        # The command used to shut down the system
        poweroff = [ "systemctl" "poweroff" ];
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

