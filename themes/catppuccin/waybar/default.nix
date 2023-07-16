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
          "mpd"
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
          "custom/shutdown"
        ];

        "custom/shutdown" = {
          format = mkIcon "";
          on-click = "${lib.getExe pkgs.wlogout}";
          tooltip = false;
          interval = "once";
        };

        "hyprland/window" = {
          format = "{}";
        };

        "wlr/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          on-click = "activate";
          # format = "{icon}";
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
          format = "{:${mkIcon ""} %R  ${mkIcon ""} %a. %d, %b.}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
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

        mpd = {
          format = "${mkIcon "{stateIcon}"} {title}";
          tooltip-format = "{albumArtist} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S})";
          format-stopped = "${mkIcon "󰙧"} Stopped";
          state-icons = {
            playing = "󰫔";
            paused = "󰏦";
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

    '' + builtins.readFile ./style.css;
  };
}

