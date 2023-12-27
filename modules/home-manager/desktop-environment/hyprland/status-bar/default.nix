{ os-config, config, lib, pkgs, extra-types, ... }:

with lib;

let
  cfg = config.hellebore.desktop-environment.hyprland.status-bar;
  theme = config.hellebore.theme.themes.${config.hellebore.theme.name}.waybar {
    inherit os-config config cfg;
  };
in
{
  options.hellebore.desktop-environment.hyprland.status-bar = {
    enable = mkEnableOption "Hellebore Waybar configuration";

    fontSize = extra-types.fontSize {
      default = config.hellebore.font.size;
      description = "Set the status bar font size.";
    };

    backlight-device = mkOption {
      type = types.nonEmptyStr;
      default = "";
      description = "Defines the backlight device to use.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> config.wayland.windowManager.hyprland.enable;
        message = "Waybar depends on Hyprland for its modules. Please enable
        Hyprland in your configuration";
      }
    ];

    home.packages = with pkgs; [
      sutils
      libappindicator-gtk3
      brightnessctl
      wttrbar
    ];

    systemd.user.targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = [ "graphical-session-pre.target" ];
      };
    };

    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        target = "hyprland-session.target";
      };

      inherit (theme) settings style;
    };
  };
}

