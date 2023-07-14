{ pkgs, lib, colors } :

rec {
  mkIcon = icon: "<big>${icon}</big>";

  extraPackages = with pkgs; [
    sutils
    libappindicator-gtk3
    brightnessctl
  ];

  waybar = {
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 0;
        modules-left = [
          "clock"
          "wlr/workspaces"
        ];
        modules-center = [
          "hyprland/window"
        ];
        modules-right = [
          "tray"
          "idle_inhibitor"
          # "custom/language"
          "network"
          "backlight"
          "wireplumber"
          "battery"
        ];

        "hyprland/window" = {
          format = "{}";
        };

        "wlr/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          on-click = "activate";
          # format = "{icon}";
          persistent_workspaces = {
            "1" = [];
            "2" = [];
            "3" = [];
            "4" = [];
            "5" = [];
            "6" = [];
            "7" = [];
            "8" = [];
            "9" = [];
            "10" = [];
          };
        };

        idle_inhibitor = {
          format = mkIcon "{icon}";
          format-icons = {
            deactivated = "󰅶";
            activated = "󰶞";
          };
          tooltip-format-activated = "Active";
          tooltip-format-deactivated = "Inactive";
        };

        # "custom/language" = {
        #   exec = "cat /tmp/kb_layout";
        #   interval = 3;
        #   format = "󰌌 {}";
        # };

        tray = {
          icon-size = 13;
          spacing = 10;
        };

        backlight = {
          device = "intel_backlight";
          format = "${mkIcon "{icon}"} {percent}%";
          format-icons = ["" "" "" "" "" "" "" "" "" "" "󰽢" ""];
          on-scroll-up = "${lib.getExe pkgs.brightnessctl} set 1%+";
          on-scroll-down = "${lib.getExe pkgs.brightnessctl} set 1%-";
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
          format = "{:${mkIcon ""} %R  ${mkIcon ""} %d/%m}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt>{calendar}</tt>";
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            weeks-pos = "right";
            format = {
              months = "<span color='${colors.mauve}'><b>{}</b></span>";
              days = "<span color='${colors.lavender}'><b>{}</b></span>";
              weeks = "<span color='${colors.teal}'><b>W{}</b></span>";
              weekdays = "<span color='${colors.blue}'><b>{}</b></span>";
              today = "<span color='${colors.red}'><b><u>{}</u></b></span>";
            };
          };
        };

        network = {
          format-wifi = "${mkIcon ""} {essid}";
          format-ethernet = "${mkIcon "󰈀"} {essid}";
          format-linked = "${mkIcon "󰈀"} {ifname} (No IP)";
          format-disconnected = "${mkIcon "󰒏"} Disconnected";
          tooltip-format-wifi = "Signal Strenght: {signalStrength}% | Down Speed: {bandwidthDownBits}, Up Speed: {bandwidthUpBits}";
          # on-click = "wofi-wifi-menu";
        };

        wireplumber = {
          format = "${mkIcon "{icon}"} {volume}%";
          format-muted = mkIcon "󰖁";
          on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-scroll-up = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 1%+";
          on-scroll-down = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 1%-";
          format-icons = [ "" "" "" ];
        };
      };
    };

    style = ''
    * {
      border: none;
      border-radius: 0;
      font-family: 'Fira Code Nerd Font Mono';
      font-weight: bold;
      font-size: 10pt;
      min-height: 0;
    }

    window#waybar {
      background: rgba(21, 18, 27, 0);
      color: ${colors.text};
    }

    tooltip {
      background: ${colors.base};
      border-radius: 10px;
      border-width: 1px;
      border-style: solid;
      border-color: ${colors.mantle};
    }

    #workspaces button {
      color: ${colors.surface0};
      margin-right: .1rem;
      padding: .15rem .2rem;
    }

    #workspaces button.active {
      color: ${colors.subtext1};
    }

    #workspaces button.focused {
      color: ${colors.subtext1};
      background: ${colors.red};
    }

    #workspaces button.urgent {
      color: ${colors.subtext1};
      background: ${colors.green};
    }

    #workspaces button:hover {
      background: ${colors.mauve};
      color: ${colors.base};
      border-radius: 9999px;
    }

    #custom-language,
    #idle_inhibitor,
    #window,
    #clock,
    #battery,
    #wireplumber,
    #network,
    #workspaces,
    #tray,
    #backlight {
      background: ${colors.base};
      padding: 0px 10px;
      margin: 3px 0px;
      margin-top: 10px;
      border: 1px solid ${colors.mantle};
    }

    #workspaces {
      padding: 0;
    }

    #tray {
      border-radius: 10px;
      margin-right: 10px;
    }

    #workspaces {
      background: ${colors.base};
      border-radius: 10px;
      margin-left: 10px;
      padding-right: 0px;
      padding-left: 5px;
    }

    #idle_inhibitor {
      color: ${colors.sapphire};
      border-radius: 10px 0px 0px 10px;
      border-right: 0px;
      margin-left: 10px;
    }

    #custom-language {
      color: ${colors.red};
      border-left: 0px;
      border-right: 0px;
    }

    #window {
      border-radius: 10px;
      margin-left: 60px;
      margin-right: 60px;
    }

    #clock {
      color: ${colors.yellow};
      border-radius: 10px;
      margin-left: 10px;
    }

    #network {
      color: ${colors.peach};
      border-left: 0px;
      border-right: 0px;
    }

    #wireplumber {
      color: ${colors.blue};
      border-left: 0px;
      border-right: 0px;
    }

    #battery {
      color: ${colors.teal};
      border-radius: 0 10px 10px 0;
      margin-right: 10px;
      border-left: 0px;
    }

    #backlight {
      color: ${colors.mauve};
      border-left: 0px;
      border-right: 0px;
    }
    '';
  };
}

