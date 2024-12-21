{
  lib,
  config,
  os-config,
  pkgs,
  ...
}: let
  inherit
    (lib)
    concatStringsSep
    optionalString
    getExe
    optional
    optionals
    flatten
    range
    mkIf
    mapAttrsToList
    removeSuffix
    pipe
    filter
    concatStrings
    foldAttrs
    mkMerge
    ;

  cfg = config.hellebore.desktop-environment.hyprland;

  theme =
    config.hellebore.theme.themes.${cfg.theme};

  configure-gtk = gtkTheme: let
    schema = pkgs.gsettings-desktop-schemas;
    datadir = "${schema}/share/gsettings-schemas/${schema.name}";
  in
    pkgs.writeShellScriptBin "configure-gtk" ''
      #!/usr/bin/env bash
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      local gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme ${gtkTheme.theme.name}
      gsettings set $gnome_schema icon-theme ${gtkTheme.iconTheme.name}
      gsettings set $gnome_schema cursor-theme ${gtkTheme.cursorTheme.name}
      gsettings set $gnome_schema font-name ${gtkTheme.font.name}
      gsettings set $gnome_schema color-scheme "prefer-dark"
    '';

  mkWindowOrLayerRule = regex: rules: map (rule: "${rule},${regex}") rules;

  mkWorkspaceRule = selector: rules: map (rule: "${selector},${rule}") rules;

  mkMonitor = monitor: let
    inherit (monitor) name;
    width = toString monitor.width;
    height = toString monitor.height;
    xOffset = toString monitor.xOffset;
    yOffset = toString monitor.yOffset;
    refreshRate = toString monitor.refreshRate;
    scaling = toString monitor.scaling;
    extraArgs = concatStringsSep "," monitor.extraArgs;
    resolution =
      if monitor.resolution == ""
      then "${width}x${height}@${refreshRate}"
      else monitor.resolution;
  in "${name},${resolution},${xOffset}x${yOffset},${scaling},${extraArgs}";

  mkMonitors = monitors: builtins.map mkMonitor monitors;

  mkExtraRules = rules:
    pipe rules [
      (map (rule: mkWindowOrLayerRule rule.regex rule.rules))
    ];

  mkExtraWorkspaceRules = workspaceRules:
    pipe workspaceRules [
      (map (rule: mkWorkspaceRule rule.selector rule.rules))
    ];

  pwas = pipe cfg.progressiveWebApps [
    (mapAttrsToList (name: value: value))
    (filter (item: item.enable))
  ];

  mkPWAExec = pwas:
    map (item: let
      execRules =
        if (builtins.length item.execRules) == 0
        then ""
        else "[${removeSuffix "; " (concatStringsSep "; " item.execRules)}]";
    in "${execRules} ${getExe pkgs.firefoxpwa} site launch ${item.id}")
    pwas;

  mkPWAWindowRules = pwas:
    pipe pwas [
      (map (item: {
        regex = "class:(FFPWA-${item.id})";
        rules = item.windowRules;
      }))
      mkExtraRules
    ];

  extraWindowRules = mkExtraRules cfg.extraWindowRules;

  extraLayerRules = mkExtraRules cfg.extraLayerRules;

  extraWorkspaceRules = mkExtraWorkspaceRules cfg.extraWorkspaceRules;

  getMonitor = index: builtins.elemAt cfg.monitors index;

  appletsConfig = config.programs.rofi.applets;

  pInPPositions = {
    bottom-left = "5 86%";
    center-left = "5 40%";
    top-left = "5 6%";
    bottom-center = "40% 86%";
    top-center = "40% 6%";
    bottom-right = "87% 86%";
    center-right = "87% 40%";
    top-right = "87% 6%";
  };

  pInPName = "^.*(Picture-in-Picture).*$";

  pInPSize = "${toString ((getMonitor 0).width / cfg.picture-in-picture.ratio)} ${toString ((getMonitor 0).height / cfg.picture-in-picture.ratio)}";

  binds = pipe cfg.extraBinds [
    (map (item: {"bind${concatStrings item.flags}" = [item.bind];}))
    (foldAttrs (bind: acc: bind ++ acc) [])
  ];

  obsSceneBinds = pipe cfg.submaps.obs.sceneBinds [
    (map (item: ''
      bind = ${item.keys}, exec, ${getExe obsCli} set-scene '${item.scene}'
      bind = ${item.keys}, submap, reset
    ''))
    (concatStringsSep "\n")
  ];

  hyprscrollerCfg = cfg.hyprscroller;
  obsCli = config.hellebore.multimedia.obs-studio.cli.package;

  submapMoveFocus = concatStringsSep "\n" [
    ''
      bind = $mainMod, left, movefocus, l
      bind = $mainMod, right, movefocus, r
      bind = $mainMod, up, movefocus, u
      bind = $mainMod, down, movefocus, d

      bind = $mainMod SHIFT, right, workspace, e+1
      bind = $mainMod SHIFT, left, workspace, e-1
    ''
    (optionalString hyprscrollerCfg.enable ''
      bind = $mainMod, KP_Home, scroller:movefocus, begin
      bind = $mainMod, KP_End, scroller:movefocus, end
    '')
  ];
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      extraConfig = concatStringsSep "\n" (flatten [
        (optionals hyprscrollerCfg.enable [
          ''
            # Center
            bind = $mainMod CTRL, W, submap, center
            submap = center
            bind = , C, scroller:alignwindow, c
            bind = , C, submap, reset
            bind = , m, scroller:alignwindow, m
            bind = , m, submap, reset
            bind = , right, scroller:alignwindow, r
            bind = , right, submap, reset
            bind = , left, scroller:alignwindow, l
            bind = , left, submap, reset
            bind = , up, scroller:alignwindow, u
            bind = , up, submap, reset
            bind = , down, scroller:alignwindow, d
            bind = , down, submap, reset
            bind = , escape, submap, reset
            submap = reset

            # Resize
            bind = $mainMod, W, submap, resize
            submap = resize
          ''
          submapMoveFocus
          ''
            binde = , right, resizeactive, 100 0
            binde = , left, resizeactive, -100 0
            binde = , up, resizeactive, 0 -100
            binde = , down, resizeactive, 0 100
            bind = , escape, submap, reset
            submap = reset

            # Fit size
            bind = $mainMod SHIFT, W, submap, fitsize
            submap = fitsize
          ''
          submapMoveFocus
          ''
            bind = , W, scroller:fitsize, visible
            bind = , W, submap, reset
            bind = , right, scroller:fitsize, toend
            bind = , right, submap, reset
            bind = , left, scroller:fitsize, tobeg
            bind = , left, submap, reset
            bind = , up, scroller:fitsize, active
            bind = , up, submap, reset
            bind = , down, scroller:fitsize, all
            bind = , down, submap, reset
            bind = , escape, submap, reset
            submap = reset

            # Trails and Trailmarks
            bind = $mainMod SHIFT, semicolon, submap, trail
            submap = trail
          ''
          submapMoveFocus
          ''
            bind = , bracketright, scroller:trailnext,
            bind = , bracketleft, scroller:trailprevious,
            bind = , semicolon, scroller:trailnew,
            bind = , semicolon, submap, reset
            bind = , D, scroller:traildelete,
            bind = , D, submap, reset
            bind = , C, scroller:trailclear,
            bind = , C, submap, reset
            bind = , V, scroller:trailtoselection,
            bind = , V, submap, reset
            bind = , escape, submap, reset
            submap = reset

            bind = $mainMod, semicolon, submap, trailmark
            submap = trailmark
            bind = , parenright, scroller:trailmarknext,
            bind = , parenleft, scroller:trailmarkprevious,
            bind = , semicolon, scroller:trailmarktoggle,
            bind = , semicolon, submap, reset
            bind = , escape, submap, reset
            submap = reset

            # Selections
            bind = $mainMod, V, submap, selection
            submap = selection
          ''
          submapMoveFocus
          ''
            bind = , A, scroller:selectiontoggle,
            bind = , R, scroller:selectionreset,

            bind = , right, scroller:selectionmove, right
            bind = , right, submap, reset
            bind = , left, scroller:selectionmove, left
            bind = , left, submap, reset
            bind = , up, scroller:selectionmove, up
            bind = , up, submap, reset
            bind = , down, scroller:selectionmove, down
            bind = , down, submap, reset
            bind = , KP_End, scroller:selectionmove, end
            bind = , KP_End, submap, reset
            bind = , KP_Begin, scroller:selectionmove, begin
            bind = , KP_Begin, submap, reset

            bind = , escape, scroller:selectionreset,
            bind = , escape, submap, reset
            submap = reset

            # Marks
            bind = $mainMod, apostrophe, submap, marks
            submap = marks
            bind = SHIFT, A, scroller:marksadd, a
            bind = SHIFT, A, submap, reset
            bind = SHIFT, B, scroller:marksadd, b
            bind = SHIFT, B, submap, reset
            bind = SHIFT, C, scroller:marksadd, c
            bind = SHIFT, C, submap, reset

            bind = CTRL, A, scroller:marksdelete, a
            bind = CTRL, A, submap, reset
            bind = CTRL, B, scroller:marksdelete, b
            bind = CTRL, B, submap, reset
            bind = CTRL, C, scroller:marksdelete, c
            bind = CTRL, C, submap, reset

            bind = , A, scroller:marksvisit, a
            bind = , A, submap, reset
            bind = , B, scroller:marksvisit, b
            bind = , B, submap, reset
            bind = , C, scroller:marksvisit, c
            bind = , C, submap, reset

            bind = , escape, submap, reset
            submap = reset
          ''
        ])

        (optionals cfg.submaps.obs.enable [
          ''
            bind = $mainMod, exclam, submap, obs
            submap = obs
            bind = , S, exec, ${getExe obsCli} toggle-stream
            bind = , S, submap, reset
            bind = , R, exec, ${getExe obsCli} toggle-record
            bind = , R, submap, reset
            bind = , M, exec, ${getExe obsCli} toggle-mute
            bind = , M, submap, reset
          ''
          obsSceneBinds
          ''
            bind = , escape, submap, reset
            submap = reset
          ''
        ])

        (optionalString cfg.submaps.discord.enable ''
          bind = $mainMod, colon, submap, discord
          submap = discord
          bind = , M, sendshortcut, CTRL SHIFT, M, vesktop
          bind = , M, submap, reset
          bind = , D, sendshortcut, CTRL SHIFT, D, vesktop
          bind = , D, submap, reset

          bind = , escape, submap, reset
          submap = reset
        '')
      ]);

      settings = mkMerge [
        theme.hyprland.settings

        {
          "$mainMod" = "SUPER";
          "$mainModKey" = "SUPER_L";

          general = {
            layout = cfg.layout;
          };

          misc = {
            middle_click_paste = cfg.misc.middleClickPaste;
            font_family = cfg.misc.font.name;
          };

          monitor = mkMonitors cfg.monitors;

          env =
            [
              "XCURSOR_THEME,${cfg.cursor.name}"
              "XCURSOR_SIZE,${toString cfg.cursor.size}"
              # "HYPRCURSOR_THEME,${cfg.cursor.name}"
              # "HYPRCURSOR_SIZE,${toString cfg.cursor.size}"
            ]
            ++ optionals os-config.hellebore.hardware.nvidia.proprietary.prime.sync.enable [
              "LIBVA_DRIVER_NAME,nvidia"
              "__GLX_VENDOR_LIBRARY_NAME,nvidia"
            ];

          cursor = {
            no_hardware_cursors = !cfg.cursor.hardwareCursors;
            allow_dumb_copy = cfg.cursor.hardwareCursors;
          };

          workspace = flatten extraWorkspaceRules;

          windowrulev2 = flatten [
            (optionals cfg.picture-in-picture.enable (mkWindowOrLayerRule "class:^.*(firefox).*$, title:${pInPName}" [
              "float"
              "pin"
              "size ${pInPSize}"
              "suppressevent fullscreen maximize"
              "noinitialfocus"
              "move ${pInPPositions.${cfg.picture-in-picture.position}}"
            ]))
            (mkPWAWindowRules pwas)
            extraWindowRules
          ];

          layerrule = flatten [
            (optionals config.hellebore.desktop-environment.logout.useLayerBlur (mkWindowOrLayerRule "logout_dialog" [
              "blur"
              "xray off"
            ]))
            extraLayerRules
          ];

          unbinds = cfg.extraUnbinds;

          exec-once =
            [
              "${getExe pkgs.swww} init"
              "sleep 5; ${getExe pkgs.swww} img ${cfg.wallpaper}"
              (optionalString config.gtk.enable "${getExe (configure-gtk theme.gtk)}")
              (optionalString os-config.hardware.logitech.wireless.enableGraphical
                "${pkgs.solaar}/bin/solaar --window hide")
            ]
            ++ mkPWAExec pwas
            ++ optional cfg.bugFixes.cursorRenderingInXWaylandApps "${getExe pkgs.xorg.xsetroot} -cursor_name left_ptr"
            ++ cfg.extraExecOnce;

          exec = cfg.extraExec;

          bind = flatten [
            ", code:107, exec, ${getExe pkgs.screenshot} area"
            "$mainMod, code:107, exec, ${getExe pkgs.screenshot} screen"

            "$mainMod, C, killactive,"
            "$mainMod, E, exec, nemo"
            "$mainMod, P, exec, ${getExe pkgs.hyprpicker} -a"

            "$mainMod, J, togglesplit," # Dwindle
            "$mainMod, M, fullscreen, 1" # Maximize window
            "$mainMod, F, fullscreen, 0" # fullscreen window
            "$mainMod SHIFT, F, togglefloating,"

            "$mainMod, left, movefocus, l"
            "$mainMod, right, movefocus, r"
            "$mainMod, up, movefocus, u"
            "$mainMod, down, movefocus, d"

            "$mainMod ALT, left, movewindow, l"
            "$mainMod ALT, right, movewindow, r"
            "$mainMod ALT, up, movewindow, u"
            "$mainMod ALT, down, movewindow, d"

            "$mainMod SHIFT, right, workspace, e+1"
            "$mainMod SHIFT, left, workspace, e-1"
            "$mainMod CTRL, right, movetoworkspace, +1"
            "$mainMod CTRL, left, movetoworkspace, -1"

            "$mainMod, mouse_down, workspace, e+1"
            "$mainMod, mouse_up, workspace, e-1"

            # Switch workspaces with mainMod + F[1-10]
            (
              map
              (item: "$mainMod, F${toString item}, workspace, ${toString item}")
              (range 1 10)
            )

            # Move active window to a workspace with mainMod + CONTROL + F[1-10]
            (
              map
              (item: "$mainMod CONTROL, F${toString item}, movetoworkspace, ${toString item}")
              (range 1 10)
            )

            (optional config.hellebore.desktop-environment.logout.enable
              "$mainMod, L, exec, ${config.hellebore.desktop-environment.logout.bin}")
            (optional config.hellebore.shell.emulator.enable
              "$mainMod, Q, exec, ${config.hellebore.shell.emulator.bin}")
            (optional config.hellebore.desktop-environment.applications-launcher.enable
              "$mainMod, R, exec, ${config.hellebore.desktop-environment.applications-launcher.command}")
            (optional config.hellebore.desktop-environment.i18n.enable
              "$mainMod, I, exec, fcitx5-remote -t")

            # Rofi Applets
            (optional appletsConfig.favorites.enable
              "$mainMod SHIFT, R, exec, ${getExe appletsConfig.favorites.package}")

            (optional appletsConfig.quicklinks.enable
              "$mainMod CTRL, R, exec, ${getExe appletsConfig.quicklinks.package}")

            (optional appletsConfig.bluetooth.enable
              "$mainMod, B, exec, ${getExe appletsConfig.bluetooth.package}")

            (optional appletsConfig.mpd.enable
              "$mainMod, A, exec, ${getExe appletsConfig.mpd.package}")

            (optional appletsConfig.ronema.enable
              "$mainMod, N, exec, ${getExe appletsConfig.ronema.package}")

            (optional appletsConfig.power-profiles.enable
              "$mainMod, Z, exec, ${getExe appletsConfig.power-profiles.package}")

            "$mainMod SHIFT, Q, exec, ${getExe pkgs.qalculate-gtk}"

            (
              optional os-config.hellebore.games.steam.enable
              "$mainMod, S, exec, ${getExe os-config.hellebore.games.steam.package}"
            )
            (
              optional os-config.hellebore.games.gamescope.enable
              "$mainMod SHIFT, S, exec, steam-gamescope"
            )

            (optional cfg.switches.lid.enable ", switch:[${cfg.switches.lid.name}], exec, ${config.hellebore.desktop-environment.lockscreen.bin} --lid")
          ];

          bindl = [
            ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ];

          bindle = [
            ", XF86AudioRaiseVolume, exec, ${getExe pkgs.volume-brightness} -v 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
            ", XF86AudioLowerVolume, exec, ${getExe pkgs.volume-brightness} -v 1.5 @DEFAULT_AUDIO_SINK@ 5%-"
            ", XF86MonBrightnessUp, exec, ${getExe pkgs.volume-brightness} -b 5%+"
            ", XF86MonBrightnessDown, exec, ${getExe pkgs.volume-brightness} -b 5%-"
          ];

          bindm = [
            "$mainMod, mouse:272, movewindow"
            "$mainMod, mouse:273, resizewindow"
          ];

          input = {
            kb_layout = cfg.input.keyboard.layout;
            kb_variant = cfg.input.keyboard.variant;

            follow_mouse = 1;

            scroll_factor = cfg.input.mouse.scrollFactor;

            touchpad = {
              natural_scroll = toString cfg.input.touchpad.naturalScroll;
              tap-to-click = toString cfg.input.touchpad.tapToClick;
              scroll_factor = cfg.input.touchpad.scrollFactor;
            };

            sensitivity = toString cfg.input.mouse.sensitivity; # -1.0 - 1.0, 0 means no modification.
          };

          plugin = {
            touch_gestures = mkIf cfg.input.touchscreen.enable {
              sensitivity = cfg.input.touchscreen.sensitivity;
              workspace_swipe_fingers = cfg.input.touchscreen.workspaceSwipeFingers;
              long_press_delay = cfg.input.touchscreen.longPressDelay;
              resize_on_border_long_press = cfg.input.touchscreen.resizeWindowsByLongPressing;
              edge_margin = cfg.input.touchscreen.edgeMargin;
            };
          };

          dwindle = {
            pseudotile = true;
            preserve_split = true;
          };

          gestures = {
            workspace_swipe = false;
          };
        }

        (mkIf hyprscrollerCfg.enable {
          plugin = {
            scroller = {
              column_default_width = hyprscrollerCfg.settings.defaultColumnWidth;
              window_default_height = hyprscrollerCfg.settings.defaultWindowHeight;
              focus_wrap = hyprscrollerCfg.settings.focusWrap;
              center_row_if_space_available = hyprscrollerCfg.settings.centerRowIfSpaceAvailable;
              overview_scale_content = hyprscrollerCfg.settings.overviewScaleContent;
              column_widths = concatStringsSep " " hyprscrollerCfg.settings.columnWidths;
              window_heights = concatStringsSep " " hyprscrollerCfg.settings.windowHeights;
              jump_labels_scale = hyprscrollerCfg.settings.jumpLabels.scale;
              jump_labels_keys = concatStrings hyprscrollerCfg.settings.jumpLabels.keys;
              gesture_scroll_enable = hyprscrollerCfg.settings.gestures.scroll.enable;
              gesture_scroll_fingers = hyprscrollerCfg.settings.gestures.scroll.fingers;
              gesture_scroll_distance = hyprscrollerCfg.settings.gestures.scroll.distance;
              gesture_overview_enable = hyprscrollerCfg.settings.gestures.overview.enable;
              gesture_overview_fingers = hyprscrollerCfg.settings.gestures.overview.fingers;
              gesture_overview_distance = hyprscrollerCfg.settings.gestures.overview.distance;
              gesture_workspace_switch_prefix = hyprscrollerCfg.settings.gestures.workspaceSwitchPrefix;
            };
          };

          bind = [
            # Extra move focus
            "$mainMod, KP_Home, scroller:movefocus, begin"
            "$mainMod, KP_End, scroller:movefocus, end"

            # Extra move windows
            "$mainMod ALT, KP_Home, scroller:movewindow, begin"
            "$mainMod ALT, KP_End, scroller:movewindow, end"

            # Switch between Col and Row
            "$mainMod, parenleft, scroller:setmode, row"
            "$mainMod, parenright, scroller:setmode, col"

            # Cycle size
            "$mainMod, KP_Add, scroller:cyclewidth, next"
            "$mainMod, KP_Subtract, scroller:cyclewidth, prev"
            "$mainMod SHIFT, KP_Add, scroller:cycleheight, next"
            "$mainMod SHIFT, KP_Subtract, scroller:cycleheight, prev"

            # Admit/Expel
            "$mainMod, I, scroller:admitwindow,"
            "$mainMod, O, scroller:expelwindow,"

            # Overview
            "$mainMod, tab, scroller:toggleoverview"

            # Pin Windows
            "$mainMod SHIFT, P, scroller:pin,"

            # Reset Marks
            "$mainMod SHIFT, apostrophe, scroller:marksreset"

            # Jump
            "$mainMod, G, scroller:jump,"
          ];
        })
        binds
      ];
    };
  };
}
