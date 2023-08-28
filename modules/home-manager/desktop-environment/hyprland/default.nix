{ nixosConfig, config, lib, ... }:

with lib;

let
  cfg = config.hellebore.desktop-environment.hyprland;
in
{
  imports = [
    ./wlogout.nix
    ./swaylock.nix
    ./dunst.nix
    ./anyrun.nix
    ./waybar
  ];

  options.config.hellebore.desktop-environment.hyprland = {
    enable = mkEnableOption "Hellebore Hyprland configuration";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> nixosConfig.programs.hyprland.enable;
        message = "Hyprland must be enabled in your system configuration";
      }
      {
        assertion = cfg.enable -> nixosConfig.programs.hyprland.xwayland.enable;
        message = "Hyprland XWayland must be enabled in your system configuration";
      }
      {
        assertion = cfg.enable -> nixosConfig.programs.hyprland.xwayland.hidpi;
        message = "Hyprland XWayland HiDPI must be enabled in your system
        configuration";
      }
    ];

    home.packages = with pkgs; [
      swww
      swayosd
      wl-clipboard
    ];

    gtk = {
      enable = true;
      inherit (theme.gtk) theme cursorTheme iconTheme font;

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };

      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland = {
        enable = true;
        hidpi = true;
      };
      systemdIntegration = true;
      recommendedEnvironment = true;
      extraConfig = ''
        source = ${theme.hyprland.palette}
        exec-once = hyprctl setcursor ${theme.gtk.cursorTheme.name} 24

      '';
    };
  };
}

