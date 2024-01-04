{ os-config, config, lib, pkgs, extra-types, ... }:


let
  inherit (lib) mkIf mkOption mkEnableOption elemAt types getExe recursiveUpdate
  flatten optional optionalString concatStringsSep;
  cfg = config.hellebore.desktop-environment.status-bar;
  theme = config.hellebore.theme.themes.${config.hellebore.theme.name};
  waybar-theme = theme.waybar modules;
  modules = {
    modules = flatten [
      "custom/icon"
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

    followGTKTheme = (mkEnableOption null) // {
      description  = "Make the status bar follow the GTK Theme applied globally";
    };

    font = extra-types.font {
      size = config.hellebore.font.size;
      name = theme.gtk.font.name;
      sizeDescription = "Set the status bar font size.";
      nameDescription = "Set the status bar font family.";
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

      settings = recursiveUpdate waybar-theme.settings {
        mainBar = {
          output = (elemAt config.hellebore.monitors 0).name;

          "custom/weather" = {
            tooltip = true;
            interval = 3600;
            exec = "${getExe pkgs.wttrbar} --custom-indicator '{ICON} {temp_C}°C ({FeelsLikeC}°C)'";
            return-type = "json";
          };

          "custom/quit" = {
            on-click = "hyprctl dispatch exit";
          };

          "custom/lock" = {
            on-click = "swaylock -fF";
          };

          "custom/reboot" = {
            on-click = "systemctl reboot";
          };

          "custom/power" = {
            on-click = "systemctl poweroff";
          };

          bluetooth = {
            on-click = "${getExe pkgs.toggle-bluetooth}";
            on-click-right = "${pkgs.blueberry}/bin/blueberry";
          };

          backlight = {
            device = cfg.backlight-device;
            on-scroll-up = "${lib.getExe pkgs.volume-brightness} -b 1%+";
            on-scroll-down = "${lib.getExe pkgs.volume-brightness} -b 1%-";
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
            on-click-right = "${lib.getExe pkgs.pavucontrol}";
            on-scroll-up = "${lib.getExe pkgs.volume-brightness} -v 1.5 @DEFAULT_AUDIO_SINK@ 1%+";
            on-scroll-down = "${lib.getExe pkgs.volume-brightness} -v 1.5 @DEFAULT_AUDIO_SINK@ 1%-";
          };
        };
      };

      style = concatStringsSep "\n" [
        (optionalString (!cfg.followGTKTheme) ''
        * {
          all: unset;
        }
        '')

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

