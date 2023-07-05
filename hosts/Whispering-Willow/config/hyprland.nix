{ pkgs, lib, config, common-attrs, ... }:

{
  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-hyprland
    dunst
  ] ++ common-attrs.gtk-theme.packages;

  services.greetd = {
    enable = true;
  };

  programs.regreet = {
    enable = true;
    settings = {
      GTK = {
        # Whether to use the dark theme
        application_prefer_dark_theme = true;

        # Cursor theme name
        cursor_theme_name = common-attrs.gtk-theme.cursorTheme.name;

        # Font name and size
        font_name = "${common-attrs.gtk-theme.font.name} 20";

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

