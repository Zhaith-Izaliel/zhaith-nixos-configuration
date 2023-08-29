{ config, lib, pkgs, theme, ... }:

with lib;

let
  mkBig = icon: "<big>${icon}</big>";
  cfg = config.hellebore.desktop-environment.hyprland.waybar;
in
{
  options.hellebore.desktop-environment.hyprland.waybar = {
    enable = mkEnableOption "Hellebore Waybar configuration";
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
    ];

    systemd.user.targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = [ "graphical-session-pre.target" ];
      };
    };

    programs.waybar = {
      enable = true;
      package = pkgs.waybar-hyprland;
      systemd = {
        enable = true;
        target = "hyprland-session.target";
      };

      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          spacing = 0;
          height = 0;
          modules-left = [
            "clock"
            "mpd"
            "wlr/workspaces"
          ];
          modules-center = [
            "hyprland/window"
          ];
          modules-right = [
            "tray"
            "idle_inhibitor"
            "bluetooth"
            "network"
            "backlight"
            "wireplumber"
            "battery"
            "custom/shutdown"
          ];

          bluetooth = mkIf config.hellebore.desktop-environment.bluetooth {
            format = "󰂯 {status}";
            format-off = "󰂲 off";
            format-disabled = "󰂳 off";
            format-connected = "${mkBig "󰂱"} {device_alias}";
            format-connected-battery = "󰂱 {device_alias} {device_battery_percentage}%";
            on-click = "${lib.getExe pkgs.toggle-bluetooth}";
            on-click-right = "${pkgs.blueberry}/bin/blueberry";
            tooltip-format = "󰂯 {controller_alias} - {controller_address}\n󰂰 {num_connections} connected";
            tooltip-format-connected = "󰂯 {controller_alias} - {controller_address}\n󰂰 {num_connections} connected\n\n{device_enumerate}";
            tooltip-format-enumerate-connected = "󰥰 {device_alias} - {device_address}";
            tooltip-format-enumerate-connected-battery = "󰥰 {device_alias} - {device_address} (󰁹 {device_battery_percentage}%)";
          };

          "custom/shutdown" = mkIf config.programs.wlogout.enable {
            format = mkBig "";
            on-click = "${lib.getExe pkgs.wlogout-blur} --protocol layer-shell -b 5 -T 400 -B 400";
            tooltip = false;
            interval = "once";
          };

          "hyprland/window" = {
            format = "{}";
          };

          "wlr/workspaces" = {
            disable-scroll = true;
            all-outputs = false;
            on-click = "activate";
            sort-by-number =  true;
            format = mkBig "{icon}";
            format-icons = {
              "1" = "󰲠";
              "2" = "󰲢";
              "3" = "󰲤";
              "4" = "󰲦";
              "5" = "󰲨";
              "6" = "󰲪";
              "7" = "󰲬";
              "8" = "󰲮";
              "9" = "󰲰";
              "10" = "󰿬";
            };
            persistent_workspaces =  {
              "1" = [];
              "2" = [];
              "3" = [];
              "4" = [];
              "5" = [];
            };
          };

          idle_inhibitor = {
            format = mkBig "{icon}";
            format-icons = {
              deactivated = "󰅶";
              activated = "󰶞";
            };
            tooltip-format-activated = "Active";
            tooltip-format-deactivated = "Inactive";
          };

          tray = {
            icon-size = 13;
            spacing = 10;
          };

          backlight = {
            device = "intel_backlight";
            format = "${mkBig "{icon}"} {percent}%";
            format-icons = ["" "" "" "" "" "" "" "" "" "" "󰽢" "󰖙"];
            on-scroll-up = "${lib.getExe pkgs.volume-brightness} -b 1%+";
            on-scroll-down = "${lib.getExe pkgs.volume-brightness} -b 1%-";
            min-length = 6;
          };

          battery = {
            states = {
              good = 95;
              warning = 30;
              critical = 20;
            };

            format = "{icon} {capacity}%";
            format-charging = "󰂄 {capacity}%";
            format-plugged = " {capacity}%";
            format-icons = ["󰁺" "󰁻" "󰁼" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
          };

          clock = {
            format = "{:${mkBig ""} %R  ${mkBig ""} %a. %d, %b.}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            calendar = {
              mode = "month";
              mode-mon-col = 3;
              weeks-pos = "right";
              format = {
                months = "<span color='${theme.colors.mauve}'><b>{}</b></span>";
                days = "<span color='${theme.colors.lavender}'><b>{}</b></span>";
                weeks = "<span color='${theme.colors.teal}'><b>W{}</b></span>";
                weekdays = "<span color='${theme.colors.blue}'><b>{}</b></span>";
                today = "<span color='${theme.colors.red}'><b><u>{}</u></b></span>";
              };
            };
          };

          network = {
            format-wifi = "${mkBig ""} {essid}";
            format-ethernet = "${mkBig "󰈀"} {ifname}";
            format-linked = "${mkBig "󰈀"} {ifname} (No IP)";
            format-disconnected = "${mkBig "󰒏"} Disconnected";
            tooltip-format-wifi = "Signal Strenght: {signalStrength}% | Down Speed: {bandwidthDownBits}, Up Speed: {bandwidthUpBits}";
          };

          wireplumber = {
            format = "${mkBig "{icon}"} {volume}%";
            format-muted = mkBig "󰖁";
            on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            on-click-right = "${lib.getExe pkgs.pavucontrol}";
            on-scroll-up = "${lib.getExe pkgs.volume-brightness} -v 1.5 @DEFAULT_AUDIO_SINK@ 1%+";
            on-scroll-down = "${lib.getExe pkgs.volume-brightness} -v 1.5 @DEFAULT_AUDIO_SINK@ 1%-";
            format-icons = [ "" "" "" ];
          };

          mpd = mkIf config.services.mpd.enable {
            format = "${mkBig "{stateIcon}"} {title}";
            tooltip-format = "{albumArtist} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S})";
            format-stopped = "${mkBig "󰙧"} Stopped";
            state-icons = {
              playing = "󰫔";
              paused = "󰏦";
            };
          };
        };
      };

      style = ''
      @define-color base   ${theme.colors.base};
      @define-color mantle ${theme.colors.mantle};
      @define-color crust  ${theme.colors.crust};

      @define-color text     ${theme.colors.text};
      @define-color subtext0 ${theme.colors.subtext0};
      @define-color subtext1 ${theme.colors.subtext1};

      @define-color surface0 ${theme.colors.surface0};
      @define-color surface1 ${theme.colors.surface1};
      @define-color surface2 ${theme.colors.surface2};

      @define-color overlay0 ${theme.colors.overlay0};
      @define-color overlay1 ${theme.colors.overlay1};
      @define-color overlay2 ${theme.colors.overlay2};

      @define-color blue      ${theme.colors.blue};
      @define-color lavender  ${theme.colors.lavender};
      @define-color sapphire  ${theme.colors.sapphire};
      @define-color sky       ${theme.colors.sky};
      @define-color teal      ${theme.colors.teal};
      @define-color green     ${theme.colors.green};
      @define-color yellow    ${theme.colors.yellow};
      @define-color peach     ${theme.colors.peach};
      @define-color maroon    ${theme.colors.maroon};
      @define-color red       ${theme.colors.red};
      @define-color mauve     ${theme.colors.mauve};
      @define-color pink      ${theme.colors.pink};
      @define-color flamingo  ${theme.colors.flamingo};
      @define-color rosewater ${theme.colors.rosewater};

      '' + builtins.readFile ./style.css;
    };
  };
}

