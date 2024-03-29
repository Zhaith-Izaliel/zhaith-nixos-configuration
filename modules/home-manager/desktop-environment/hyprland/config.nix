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
    recursiveUpdate
    count
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
    '';

  mkWindowOrLayerRule = window: rules: (map (rule: "${rule},${window}") rules);

  mkMonitor = monitor: let
    inherit (monitor) name;
    width = toString monitor.width;
    height = toString monitor.height;
    xOffset = toString monitor.xOffset;
    yOffset = toString monitor.yOffset;
    refreshRate = toString monitor.refreshRate;
    scaling = toString monitor.scaling;
    extraArgs = concatStringsSep "," monitor.extraArgs;
  in "${name},${width}x${height}@${refreshRate},${xOffset}x${yOffset},${scaling},${extraArgs}";

  mkMonitors = monitors: builtins.map mkMonitor monitors;

  mkExtraRules = rules: builtins.map (item: mkWindowOrLayerRule item.regex item.rules) rules;

  extraWindowRules = mkExtraRules cfg.extraWindowRules;

  extraLayerRules = mkExtraRules cfg.extraLayerRules;

  getMonitor = index: builtins.elemAt cfg.monitors index;

  maxPersistentWorkspaces = count (x: x) [
    true
    config.hellebore.tools.office.enable
    config.hellebore.tools.discord.enable
    config.hellebore.desktop-environment.mail.enable
    os-config.hellebore.games.enable
  ];

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
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = recursiveUpdate theme.hyprland.settings {
      "$mainMod" = "SUPER";
      "$mainModKey" = "SUPER_L";

      general = {
        layout = cfg.layout;
      };

      monitor = mkMonitors cfg.monitors;

      env = [
        "XCURSOR_SIZE,24"
      ];

      workspace =
        map
        (x: "${toString x},${optionalString (x == 1) "default:true"},persistent:true")
        (range 1 maxPersistentWorkspaces);

      windowrulev2 = flatten [
        (
          optionals config.hellebore.tools.discord.enable
          (mkWindowOrLayerRule "class:(discord|vesktop)" [
            "workspace 3 silent"
            "noinitialfocus"
          ])
        )
        (
          optionals config.hellebore.desktop-environment.mail.enable
          (mkWindowOrLayerRule "class:(thunderbird)" [
            "workspace 4 silent"
          ])
        )
        (optionals os-config.hellebore.games.enable [
          (mkWindowOrLayerRule "class:(steam)" [
            "workspace 5 silent"
          ])
          (mkWindowOrLayerRule "class:(.gamescope-wrapped)" [
            "workspace 5"
            "idleinhibit"
          ])
          (mkWindowOrLayerRule "class:(lutris)" [
            "workspace 5"
          ])
          (mkWindowOrLayerRule "class:^.*(Cartridges).*$" [
            "workspace 5 silent"
          ])
          (mkWindowOrLayerRule "class:^.*(heroic).*$" [
            "workspace 5"
          ])
        ])
        (optionals os-config.hellebore.vm.enable [
          (mkWindowOrLayerRule "title:(${os-config.hellebore.vm.name})class:(looking-glass-client)" [
            "fullscreen"
            "idleinhibit always"
            "workspace 6"
          ])
          (mkWindowOrLayerRule "class:(virt-manager)" [
            "workspace 6"
          ])
        ])
        (optionals cfg.picture-in-picture.enable (mkWindowOrLayerRule "class:^.*(firefox).*$, title:^.*(Picture-in-Picture).*$" [
          "float"
          "pin"
          "size ${toString ((getMonitor 0).width / 8)} ${toString ((getMonitor 0).height / 8)}"
          "suppressevent fullscreen maximize"
          "noinitialfocus"
          "move ${pInPPositions.${cfg.picture-in-picture.position}}"
        ]))
        extraWindowRules
      ];

      layerrule = flatten [
        (optionals config.hellebore.desktop-environment.logout.useLayerBlur (mkWindowOrLayerRule "logout_dialog" [
          "blur"
          "xray off"
        ]))
        extraLayerRules
      ];

      exec-once = flatten [
        "${getExe pkgs.swww} init"
        "sleep 5; ${getExe pkgs.swww} img ${cfg.wallpaper}"
        "swayosd --max-volume 150"
        "hyprctl setcursor ${theme.gtk.cursorTheme.name} 24"
        (optionalString config.gtk.enable "${getExe (configure-gtk theme.gtk)}")
        (optional config.hellebore.desktop-environment.browsers.enable
          "[workspace 1] ${getExe pkgs.firefox}")
        (optional config.hellebore.shell.emulator.enable
          "[workspace 1] ${config.hellebore.shell.emulator.bin}")
        (optional config.hellebore.tools.office.enable
          "[workspace 2] obsidian")
        (optional config.hellebore.tools.discord.enable
          "${getExe config.hellebore.tools.discord.finalPackage}")
        (optional config.hellebore.desktop-environment.mail.enable
          "${config.hellebore.desktop-environment.mail.bin}")
        (optionals os-config.hellebore.games.enable [
          "cartridges"
          "steam -silent"
        ])
      ];

      bind = flatten [
        ", code:107, exec, ${getExe pkgs.screenshot} area"
        "$mainMod, code:107, exec, ${getExe pkgs.screenshot} screen"

        "$mainMod, C, killactive,"
        "$mainMod, E, exec, nemo"
        "$mainMod, P, exec, hyprpicker -a"

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
        (
          optional os-config.hellebore.vm.enable
          ''
            $mainMod, W, exec, start-vm --resolution=${toString (getMonitor 0).width}x${toString (getMonitor 0).height} -Fi
          ''
        )
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

        (optional appletsConfig.power-profiles.enable
          "$mainMod, Z, exec, ${getExe appletsConfig.power-profiles.package}")
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

      bindr = [
        "CAPS, Caps_Lock, exec, swayosd --caps-lock"
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

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      gestures = {
        workspace_swipe = false;
      };
    };
  };
}
