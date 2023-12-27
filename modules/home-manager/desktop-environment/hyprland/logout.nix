{ config, lib, pkgs, extra-types, ... }:

with lib;

let
  inherit (lib) mkEnableOption mkOption mkIf getExe;
  cfg = config.hellebore.desktop-environment.hyprland.logout;
  theme = config.hellebore.theme.themes.${config.hellebore.theme.name};
in
{
  options.hellebore.desktop-environment.hyprland.logout = {
    enable = mkEnableOption "Hellebore WLogout configuration";

    font = extra-types.font {
      size = config.hellebore.font.size;
      name = config.hellebore.font.name;
      sizeDescription = "Set the font size of the logout menu.";
      nameDescription = "Set the font family of the logout menu.";
    };

    bin = mkOption {
      type = types.str;
      default = "${getExe pkgs.wlogout-blur} --protocol layer-shell -b 5 -T 400 -B 400";
      readOnly = true;
      description  = "Define the command to run the logout program.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> config.programs.swaylock.enable;
        message = "WLogout depends on Swaylock to lock the screen. Please enable
        it in your configuration.";
      }

      {
        assertion = cfg.enable -> config.wayland.windowManager.hyprland.enable;
        message = "WLogout depends on Hyprland to logout. Please enable
        it in your configuration.";
      }
    ];

    home.packages = with pkgs; [
      wlogout-blur
    ];

    programs.wlogout = {
      enable = true;
      layout = [
        {
          label = "lock";
          action = "${getExe config.programs.swaylock.package} -fF";
          text = "Lock";
          keybind = "l";
        }
        {
          label = "reboot";
          action = "${pkgs.systemd}/bin/systemctl reboot";
          text = "Reboot";
          keybind = "r";
        }
        {
          label = "shutdown";
          action = "${pkgs.systemd}/bin/systemctl poweroff";
          text = "Shutdown";
          keybind = "s";
        }
        {
          label = "logout";
          action = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch exit 0";
          text = "Logout";
          keybind = "e";
        }
        {
          label = "suspend";
          action = "${pkgs.systemd}/bin/systemctl suspend";
          text = "Suspend";
          keybind = "u";
        }
      ];

      style = ''
      window {
        font-family: "${cfg.font.name}";
        font-size: ${toString cfg.font.size}pt;
      }

      '' ++ theme.wlogout.style;
    };
  };
}

