{ colors, inputs, modules, lib }:
let
  inherit (lib) recursiveUpdate any optionalString concatStringsSep;
  mkBig = icon: "<big>${icon}</big>";
  mkWaybarModules = (import ../../../../utils/default.nix { inherit inputs; }
  ).mkWaybarModules;
  modulesPosition = {
    modules-left = [
      "custom/icon"
      "clock"
      "custom/weather"
      "hyprland/workspaces"
      "mpd"
    ];
    modules-center = [
      "hyprland/window"
    ];
    modules-right = [
      "custom/notifications"
      "tray"
      "idle_inhibitor"
      "gamemode"
      "bluetooth"
      "network"
      "backlight"
      "wireplumber"
      "battery"
      "group/power"
    ];

    "group/power" = {
      modules = [
        "custom/power"
        "custom/lock"
        "custom/logout"
        "custom/reboot"
      ];
    };
  };
  finalModules = mkWaybarModules modules modulesPosition;
in
{
  settings = {
    mainBar = recursiveUpdate {
      layer = "top";
      position = "top";
      margin-top = 20;
      margin-right = 20;
      margin-left = 20;
      spacing = 0;

      gamemode = {
        format = "{glyph} On";
        hide-not-running = true;
        use-icon = true;
        tooltip = true;
        tooltip-format = "Processes running: {count}";
        icon-spacing = 0;
      };

      "custom/weather" = {
        format = "{}";
      };

      "custom/icon" = {
        format = mkBig "🪷";
        tooltip = false;
      };

      "group/power" = {
        orientation = "inherit";
        drawer = {
          transition-duration = 500;
          children-class = "power-child";
          transition-left-to-right = false;
        };
      };

      "custom/logout" = {
        format = mkBig "󰗼";
        tooltip = false;
      };

      "custom/lock" = {
        format = mkBig "󰍁";
        tooltip = false;
      };

      "custom/reboot" = {
        format = mkBig "󰜉";
        tooltip = false;
      };

      "custom/power" = {
        format = mkBig "";
        tooltip = false;
      };

      "custom/notifications" = {
        format = "${mkBig "{icon}"} {}";
        format-icons = {
          not-paused = "";
          paused = "";
          error = "";
        };
      };

      bluetooth = {
        format = "󰂯 On";
        format-off = "${mkBig "󰂲"} Off";
        format-disabled = "󰂳 Disabled";
        format-connected = "${mkBig "󰂱"} {device_alias}";
        format-connected-battery = "${mkBig "󰂱"} {device_alias} {device_battery_percentage}%";
        tooltip-format = "󰂯 {controller_alias} - {controller_address}\n󰂰 {num_connections} connected";
        tooltip-format-connected = "󰂯 {controller_alias} - {controller_address}\n󰂰 {num_connections} connected\n\n{device_enumerate}";
        tooltip-format-enumerate-connected = "󰥰 {device_alias} - {device_address}";
        tooltip-format-enumerate-connected-battery = "󰥰 {device_alias} - {device_address} (󰁹 {device_battery_percentage}%)";
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
          "1" = "一";
          "2" = "二";
          "3" = "三";
          "4" = "四";
          "5" = "五";
          "6" = "六";
          "7" = "七";
          "8" = "八";
          "9" = "九";
          "10" = "〇";
        };

        persistent-workspaces = {
          "*" = 10;
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

      backlight = {
        format = "${mkBig "{icon}"} {percent}%";
        tooltip-format = "Brightness: {percent}%";
        format-icons = ["" "" "" "" "" "" "" "" "" "" "󰽢" "󰖨"];
        min-length = 6;
      };

      battery = {
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-plugged = " {capacity}%";
        format-icons = ["󰁺" "󰁻" "󰁼" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
      };

      clock = {
        format = "${mkBig ""} {:%H:%M}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
        calendar = {
          mode = "month";
          mode-mon-col = 3;
          weeks-pos = "right";
          on-scroll = 1;
          on-click = "mode";
          format = {
            months = "<span color='${colors.normal.mauve}'><b>{}</b></span>";
            days = "<span color='${colors.normal.lavender}'><b>{}</b></span>";
            weeks = "<span color='${colors.normal.teal}'><b>W{}</b></span>";
            weekdays = "<span color='${colors.normal.blue}'><b>{}</b></span>";
            today = "<span color='${colors.normal.red}'><b><u>{}</u></b></span>";
          };
          actions = {
            on-click = "mode";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };
      };

      network =
        let
          speedFormat = "󰮏 {bandwidthDownBits}⎹ 󰸇 {bandwidthUpBits}";
        in
        {
          format-wifi = "${mkBig "{icon}"} {essid}";
          format-ethernet = "${mkBig "󰈀"} {ipaddr}/{cidr}";
          format-linked = "${mkBig ""} {ifname}";
          format-disconnected = mkBig "󰒏";
          tooltip-format-wifi = "{essid} - {icon} {signalStrength}%\n${speedFormat}";
          tooltip-format-disconnected = "Disconnected";
          tooltip-format-ethernet = "{ifname}\n${speedFormat}";
          tooltip-format-linked = speedFormat;
          format-icons = [
            "󰤫"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
        };

        wireplumber = {
          format = "${mkBig "{icon}"} {volume}%";
          tooltip-format = "Device Node: {node_name}\nVolume: {volume}%";
          format-muted = mkBig "󰖁";
          format-icons = [ "" "" "" ];
        };

        mpd = {
          format = "${mkBig "{stateIcon}"}  {title}";
          tooltip-format = "{albumArtist} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S})\n{randomIcon} {repeatIcon} {singleIcon}";
          format-stopped = "${mkBig ""}  Stopped";
          format-disconnected = "${mkBig "󰎊"}  Disconnected";
          tooltip-format-disconnected = "Disconnected";
          state-icons = {
            playing = "󰎈";
            paused = "";
          };
          random-icons = {
            on = "󰒝 on";
            off = "󰒞 off";
          };
          repeat-icons = {
            on = "󰑖 on";
            off = "󰑗 off";
          };
          single-icons = {
            on = "󰑘 on";
            off = "󰑘 off";
          };
        };
      } finalModules;
    };

    style = concatStringsSep "\n" [
      ''
      @define-color base   ${colors.normal.base};
      @define-color mantle ${colors.normal.mantle};
      @define-color crust  ${colors.normal.crust};

      @define-color text     ${colors.normal.text};
      @define-color subtext0 ${colors.normal.subtext0};
      @define-color subtext1 ${colors.normal.subtext1};

      @define-color surface0 ${colors.normal.surface0};
      @define-color surface1 ${colors.normal.surface1};
      @define-color surface2 ${colors.normal.surface2};

      @define-color overlay0 ${colors.normal.overlay0};
      @define-color overlay1 ${colors.normal.overlay1};
      @define-color overlay2 ${colors.normal.overlay2};

      @define-color blue      ${colors.normal.blue};
      @define-color lavender  ${colors.normal.lavender};
      @define-color sapphire  ${colors.normal.sapphire};
      @define-color sky       ${colors.normal.sky};
      @define-color teal      ${colors.normal.teal};
      @define-color green     ${colors.normal.green};
      @define-color yellow    ${colors.normal.yellow};
      @define-color peach     ${colors.normal.peach};
      @define-color maroon    ${colors.normal.maroon};
      @define-color red       ${colors.normal.red};
      @define-color mauve     ${colors.normal.mauve};
      @define-color pink      ${colors.normal.pink};
      @define-color flamingo  ${colors.normal.flamingo};
      @define-color rosewater ${colors.normal.rosewater};

      ''
      (
        optionalString
        (any (item: item == "custom/notifications") modules.modules)
        ''
        #tray {
          border-left-width: 2px;
        }

        ''
      )
      (builtins.readFile ./style.css)
    ];
  }

