{
  os-config,
  config,
  lib,
  pkgs,
  extra-types,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkOption
    mkEnableOption
    types
    getExe
    recursiveUpdate
    flatten
    optional
    concatStringsSep
    optionalAttrs
    ;

  cfg = config.hellebore.desktop-environment.status-bar;
  theme = config.hellebore.theme.themes.${cfg.theme};
  waybar-theme = theme.waybar modules;
  modules = {
    modules = flatten [
      "custom/icon"
      (optional (cfg.enableSubmap && config.hellebore.desktop-environment.hyprland.enable) "hyprland/submap")
      # (optional os-config.services.power-profiles-daemon.enable "custom/power-profiles")
      (optional config.services.dunst.enable "custom/notifications")
      "clock"
      "custom/weather"
      (optional config.services.mpd.enable "mpd")
      (optional config.hellebore.desktop-environment.hyprland.enable "hyprland/workspaces")
      (optional config.hellebore.desktop-environment.hyprland.enable "hyprland/window")
      "tray"
      "idle_inhibitor"
      (optional os-config.hellebore.games.gamescope.enable "gamemode")
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

  mkBig = str: "<big>${str}</big>";
in {
  options.hellebore.desktop-environment.status-bar = {
    enable = mkEnableOption "Hellebore Waybar configuration";

    font = extra-types.font {
      size = config.hellebore.font.size;
      name = theme.gtk.font.name;
      sizeDescription = "Set the status bar font size.";
      nameDescription = "Set the status bar font family.";
    };

    theme = extra-types.theme.name {
      default = config.hellebore.theme.name;
      description = "Set the status bar theme used.";
    };

    monitors = mkOption {
      type = types.listOf types.nonEmptyStr;
      default = [];
      description = "Defines the monitor on which the status bar should be rendered";
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

    enableSubmap =
      mkEnableOption "the submap module"
      // {
        default = config.hellebore.desktop-environment.hyprland.submaps.enabled;
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

    home.packages = with pkgs;
      flatten [
        sutils
        libappindicator-gtk3
        brightnessctl
        wttrbar
        (optional config.services.dunst.enable dunstbar)
        (optional os-config.services.power-profiles-daemon.enable power-profilesbar)
        (config.hellebore.desktop-environment.lockscreen.package)
      ];

    systemd.user.targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = ["graphical-session-pre.target"];
      };
    };

    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        target = "hyprland-session.target";
      };

      settings = recursiveUpdate waybar-theme.settings {
        mainBar =
          {
            inherit (cfg) tray;

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
              exec = "${getExe pkgs.dunstbar} --history=10 -i";
              restart-interval = 5;
              on-click = "${getExe pkgs.dunstbar} -p";
              on-click-right = "${getExe pkgs.dunstbar} -c";
              return-type = "json";
            };

            "custom/power-profiles" = {
              exec = "${getExe pkgs.power-profilesbar} -i";
              restart-interval = 30;
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

            clock = {
              timezone = os-config.time.timeZone;
            };

            wireplumber = {
              on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
              on-click-right = "${getExe pkgs.pavucontrol}";
              on-scroll-up = "${getExe pkgs.volume-brightness} -v 1.5 @DEFAULT_AUDIO_SINK@ 1%+";
              on-scroll-down = "${getExe pkgs.volume-brightness} -v 1.5 @DEFAULT_AUDIO_SINK@ 1%-";
            };

            "hyprland/window" =
              {
                format = "{}";
                rewrite = {
                  "(.*) — Mozilla Firefox" = "${mkBig ""} $1";
                  "Zellij (.*)" = "${mkBig ""} $1";
                  "Discord (.*)" = "${mkBig "󰙯"} Discord";
                  "(.*) - Mozilla Thunderbird" = "${mkBig ""} $1";
                  "Cartridges" = "${mkBig "󰊗"} Cartridges";
                  "Steam" = "${mkBig "󰓓"} Steam";
                };
              }
              // (optionalAttrs cfg.enableSubmap {
                max-length = 20;
              });
          }
          // optionalAttrs (builtins.length cfg.monitors > 0) {
            output = cfg.monitors;
          };
      };

      style = concatStringsSep "\n" [
        ''
          * {
            font-size: ${toString cfg.font.size}pt;
            font-family: "${cfg.font.name}", "FiraMono Nerd Font Mono";
          }
        ''
        waybar-theme.style
      ];
    };
  };
}
