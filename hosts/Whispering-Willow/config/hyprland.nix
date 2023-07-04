{ pkgs, ... }:

let
  greetdHyprlandConfig = pkgs.writeText "hyprland-greetd.conf" ''
    regreet; hyprctl dispatch exit
  '';
in
{
  environment.systemPackages = with pkgs; [
    cinnamon.nemo
    xdg-desktop-portal-hyprland
    gnome.simple-scan
  ];

  services.greetd = {
    enable = true;
    settings = {
      terminal = {
        vt = 1;
      };
      default_session = {
        command = "${pkgs.hyprland}/bin/Hyprland --config ${greetdHyprlandConfig}";
        user = "greeter";
      };
    };
  };

  programs.regreet = {
    enable = true;
    settings = {
      GTK = {
        # Whether to use the dark theme
        application_prefer_dark_theme = true;

        # Cursor theme name
        cursor_theme_name = "Adwaita";

        # Font name and size
        font_name = "Cantarell 16";

        # Icon theme name
        icon_theme_name = "Adwaita";

        # GTK theme name
        theme_name = "Adwaita";

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
      hdi = true;
    };
    nvidiaPatches = true;
  };

}

