{ config, cfg, os-config, lib, pkgs, colors }:
let
  inherit (lib) lists mkIf getExe;
  mkBig = icon: "<big>${icon}</big>";
in
{
  settings = {
    mainBar = {
      layer = "top";
      position = "top";
      output = with config.hellebore.desktop-environment.hyprland;
      strings.optionalString enable (elemAt monitors 0).name;
      spacing = 0;
      height = 0;
      modules-left = [
        "clock"
        "custom/weather"
      ]
      ++ lists.optional config.services.mpd.enable "mpd"
      ++ [
        "hyprland/workspaces"
      ];
      modules-center = [
        "hyprland/window"
      ];
      modules-right = [
        "tray"
        "idle_inhibitor"
      ]
      ++ lists.optional os-config.programs.gamemode.enable "gamemode"
      ++ lists.optional config.hellebore.desktop-environment.bluetooth.enable "bluetooth"
      ++ [
        "network"
        "backlight"
        "wireplumber"
        "battery"
      ]
      ++ lists.optional config.programs.wlogout.enable "custom/shutdown";

      gamemode = mkIf os-config.programs.gamemode.enable {
        format = "{glyph} GameMode On";
        hide-not-running = true;
        use-icon = true;
        tooltip = true;
        tooltip-format = "Processes running: {count}";
        icon-spacing = 0;
      };

      "custom/weather" = {
        format = "{} °C";
        tooltip = true;
        interval = 3600;
        exec = "${getExe pkgs.wttrbar}";
        return-type = "json";
      };

      bluetooth = mkIf config.hellebore.desktop-environment.bluetooth.enable {
        format = "󰂯 {status}";
        format-off = "󰂲 off";
        format-disabled = "󰂳 off";
        format-connected = "${mkBig "󰂱"} {device_alias}";
        format-connected-battery = "󰂱 {device_alias} {device_battery_percentage}%";
        on-click = "${getExe pkgs.toggle-bluetooth}";
        on-click-right = "${pkgs.blueberry}/bin/blueberry";
        tooltip-format = "󰂯 {controller_alias} - {controller_address}\n󰂰 {num_connections} connected";
        tooltip-format-connected = "󰂯 {controller_alias} - {controller_address}\n󰂰 {num_connections} connected\n\n{device_enumerate}";
        tooltip-format-enumerate-connected = "󰥰 {device_alias} - {device_address}";
        tooltip-format-enumerate-connected-battery = "󰥰 {device_alias} - {device_address} (󰁹 {device_battery_percentage}%)";
      };

      "custom/shutdown" = mkIf config.programs.wlogout.enable {
        format = mkBig "";
        on-click = config.hellebore.desktop-environment.hyprland.logout.bin;
        tooltip = false;
        interval = "once";
      };

      "hyprland/window" = {
        format = "{}";
      };

      "hyprland/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
        sort-by-number =  true;
        format = mkBig "{icon}";
        format-icons = {
          "1" = "";
          "2" = "󰹕";
          "3" = "󰙯";
          "4" = "󰇮";
          "5" = "";
          "6" = "";
          "7" = "󰲬";
          "8" = "󰲮";
          "9" = "󰲰";
          "10" = "󰿬";
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
        device = cfg.backlight-device;
        format = "${mkBig "{icon}"} {percent}%";
        format-icons = ["" "" "" "" "" "" "" "" "" "" "󰽢" "󰖨"];
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
        format = "${mkBig ""} {:%H:%M}";
        timezone = os-config.time.timeZone;
        tooltip-format = "<tt><small>{calendar}</small></tt>";
        calendar = {
          mode = "month";
          mode-mon-col = 3;
          weeks-pos = "right";
          on-scroll = 1;
          on-click = "mode";
          format = {
            months = "<span color='${colors.mauve}'><b>{}</b></span>";
            days = "<span color='${colors.lavender}'><b>{}</b></span>";
            weeks = "<span color='${colors.teal}'><b>W{}</b></span>";
            weekdays = "<span color='${colors.blue}'><b>{}</b></span>";
            today = "<span color='${colors.red}'><b><u>{}</u></b></span>";
          };
          actions = {
            on-click = "mode";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
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
        format-stopped = "${mkBig ""} Stopped";
        state-icons = {
          playing = "󰎈";
          paused = "";
        };
      };
    };
  };

  style = ''
  @define-color base   ${colors.base};
  @define-color mantle ${colors.mantle};
  @define-color crust  ${colors.crust};

  @define-color text     ${colors.text};
  @define-color subtext0 ${colors.subtext0};
  @define-color subtext1 ${colors.subtext1};

  @define-color surface0 ${colors.surface0};
  @define-color surface1 ${colors.surface1};
  @define-color surface2 ${colors.surface2};

  @define-color overlay0 ${colors.overlay0};
  @define-color overlay1 ${colors.overlay1};
  @define-color overlay2 ${colors.overlay2};

  @define-color blue      ${colors.blue};
  @define-color lavender  ${colors.lavender};
  @define-color sapphire  ${colors.sapphire};
  @define-color sky       ${colors.sky};
  @define-color teal      ${colors.teal};
  @define-color green     ${colors.green};
  @define-color yellow    ${colors.yellow};
  @define-color peach     ${colors.peach};
  @define-color maroon    ${colors.maroon};
  @define-color red       ${colors.red};
  @define-color mauve     ${colors.mauve};
  @define-color pink      ${colors.pink};
  @define-color flamingo  ${colors.flamingo};
  @define-color rosewater ${colors.rosewater};

  * {
    font-size: ${toString cfg.fontSize}pt;
  }

  '' + builtins.readFile ./style.css;
}

