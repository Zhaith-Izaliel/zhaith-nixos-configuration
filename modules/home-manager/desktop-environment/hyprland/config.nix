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

  mkWindowrulev2 = window: rules: (map (rule: "${rule},${window}") rules);

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

  getMonitor = index: builtins.elemAt cfg.monitors index;

  maxPersistentWorkspaces = count (x: x) [
    true
    config.hellebore.tools.office.enable
    config.hellebore.tools.discord.enable
    config.hellebore.desktop-environment.mail.enable
    os-config.hellebore.games.enable
  ];

  appletsConfig = config.programs.rofi.applets;
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
          (mkWindowrulev2 "class:(discord)" [
            "workspace 3 silent"
            "noinitialfocus"
          ])
        )
        (
          optionals config.hellebore.desktop-environment.mail.enable
          (mkWindowrulev2 "class:(evolution)" [
            "workspace 4 silent"
          ])
        )
        (optionals os-config.hellebore.games.enable [
          (mkWindowrulev2 "class:(steam)" [
            "workspace 5 silent"
          ])
          (mkWindowrulev2 "class:(.gamescope-wrapped)" [
            "workspace 5"
            "idleinhibit"
          ])
          (mkWindowrulev2 "class:(lutris)" [
            "workspace 5"
          ])
          (mkWindowrulev2 "class:^.*(Cartridges).*$" [
            "workspace 5 silent"
          ])
          (mkWindowrulev2 "class:^.*(heroic).*$" [
            "workspace 5"
          ])
          (mkWindowrulev2 "class:(steam_app_).*" [
            "workspace 5"
            "idleinhibit"
          ])
        ])
        (optionals os-config.hellebore.vm.enable [
          (mkWindowrulev2 "title:(${os-config.hellebore.vm.name})class:(looking-glass-client)" [
            "fullscreen"
            "idleinhibit always"
            "workspace 6"
          ])
          (mkWindowrulev2 "class:(virt-manager)" [
            "workspace 6"
          ])
        ])
      ];

      exec-once = flatten [
        "${getExe pkgs.swww} init"
        "${pkgs.wl-clipboard}/bin/wl-paste -p --watch ${pkgs.wl-clipboard}/bin/wl-copy -p ''"
        "sleep 5; ${getExe pkgs.swww} img ${cfg.wallpaper}"
        "swayosd --max-volume 150"
        "hyprctl setcursor ${theme.gtk.cursorTheme.name} 24"
        (optional config.gtk.enable "configure-gtk")
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
        "$mainMod, V, togglefloating,"
        "$mainMod, P, exec, hyprpicker -a"

        "$mainMod, J, togglesplit," # Dwindle
        "$mainMod, M, fullscreen, 1" # Maximize window
        "$mainMod, F, fullscreen, 0" # fullscreen window

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
            $mainMod SHIFT, W, exec, start-vm --resolution=${toString (getMonitor 1).width}x${toString (getMonitor 1).height} -i
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
        kb_layout = "${cfg.input.kbLayout}";
        kb_variant = "${cfg.input.kbVariant}";

        follow_mouse = 1;

        touchpad = {
          natural_scroll = toString cfg.input.touchpad.naturalScroll;
          tap-to-click = toString cfg.input.touchpad.tapToClick;
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
