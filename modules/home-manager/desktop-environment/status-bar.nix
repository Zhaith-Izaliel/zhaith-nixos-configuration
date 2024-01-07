{ os-config, config, lib, pkgs, extra-types, ... }:

let
  inherit (lib) mkIf mkOption mkEnableOption elemAt types getExe recursiveUpdate
  flatten optional concatStringsSep;
  cfg = config.hellebore.desktop-environment.status-bar;
  theme = config.hellebore.theme.themes.${config.hellebore.theme.name};
  waybar-theme = theme.waybar modules;
  modules = {
    modules = flatten [
      "custom/icon"
      "custom/power-profiles"
      (optional config.services.dunst.enable "custom/notifications")
      "clock"
      "custom/weather"
      (optional config.services.mpd.enable "mpd")
      "hyprland/workspaces"
      "hyprland/window"
      "tray"
      "idle_inhibitor"
      (optional os-config.hellebore.games.enable "gamemode")
      (optional os-config.hardware.bluetooth.enable "bluetooth")
      "network"
      "backlight"
      (optional os-config.services.pipewire.wireplumber.enable "wireplumber")
      "battery"
      "group/power"
      (optional
      config.hellebore.desktop-environment.applications-launcher.enable "custom/app")
    ];

    "group/power" = [
      "custom/power"
      "custom/lock"
      "custom/logout"
      "custom/reboot"
    ];
  };
in
{
  options.hellebore.desktop-environment.status-bar = {
    enable = mkEnableOption "Hellebore Waybar configuration";

    font = extra-types.font {
      size = config.hellebore.font.size;
      name = theme.gtk.font.name;
      sizeDescription = "Set the status bar font size.";
      nameDescription = "Set the status bar font family.";
    };

    tray = {
      icon-size = mkOption {
        type = types.ints.unsigned;
        default = 10;
        description = "Defines the size of the icons in the system tray;";
      };

      spacing = mkOption {
        type = types.ints.unsigned;
        default = 5;
        description = "Defines the spacing between the icons in the system tray.";
      };
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
      dunstbar
      power-profilesbar
      (config.hellebore.desktop-environment.lockscreen.package)
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

      settings = recursiveUpdate waybar-theme.settings {
        mainBar = {
          inherit (cfg) tray;
          output = (elemAt config.hellebore.monitors 0).name;

          "custom/weather" = {
            tooltip = true;
            interval = 3600;
            exec = "${getExe pkgs.wttrbar} --custom-indicator '{ICON} {temp_C}°C ({FeelsLikeC}°C)'";
            return-type = "json";
          };

          "custom/quit" = {
            on-click = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch exit 0";
          };

          "custom/lock" = {
            on-click = "${getExe config.hellebore.desktop-environment.lockscreen.package} -fF";
          };

          "custom/reboot" = {
            on-click = "systemctl reboot";
          };

          "custom/power" = {
            on-click = "systemctl poweroff";
          };

          "custom/notifications" = {
            exec = "${getExe pkgs.dunstbar} -i";
            on-click = "${getExe pkgs.dunstbar} -p";
            on-click-right = "${getExe pkgs.dunstbar} -c";
            return-type = "json";
          };

          "custom/power-profiles" = {
            exec = "${getExe pkgs.power-profilesbar} -i";
            return-type = "json";
          };

          bluetooth = {
            on-click = "${getExe pkgs.toggle-bluetooth}";
            on-click-right = "${pkgs.blueberry}/bin/blueberry";
          };

          backlight = {
            device = cfg.backlight-device;
            on-scroll-up = "${getExe pkgs.volume-brightness} -b 1%+";
            on-scroll-down = "${getExe pkgs.volume-brightness} -b 1%-";
          };

          battery = {
            states = {
              good = 95;
              warning = 30;
              critical = 20;
            };
          };

          clock = {
            timezone = os-config.time.timeZone;
          };

          wireplumber = {
            on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            on-click-right = "${getExe pkgs.pavucontrol}";
            on-scroll-up = "${getExe pkgs.volume-brightness} -v 1.5 @DEFAULT_AUDIO_SINK@ 1%+";
            on-scroll-down = "${getExe pkgs.volume-brightness} -v 1.5 @DEFAULT_AUDIO_SINK@ 1%-";
          };
        };
      };

      style = concatStringsSep "\n" [
        ''
        * {
          font-size: ${toString cfg.font.size}pt;
          font-family: "${cfg.font.name}", "Fira Code Nerd Font Mono";
        }
        ''
        waybar-theme.style
      ];
    };
  };
}
