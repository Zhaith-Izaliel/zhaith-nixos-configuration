{ lib, config, osConfig, theme, pkgs, ... }:

let
  inherit (lib) strings getExe lists range mkIf;

  cfg = config.hellebore.desktop-environment.hyprland;

  mkWindowrulev2 = window: rules: (builtins.concatStringsSep "\n" (map (rule: "windowrulev2=${rule},${window}") rules));

  mkMonitor = monitor:
  let
    inherit (monitor) name;
    width = toString monitor.width;
    height = toString monitor.height;
    xOffset = toString monitor.xOffset;
    yOffset = toString monitor.yOffset;
    refreshRate = toString monitor.refreshRate;
    scaling = toString monitor.scaling;
  in
  "monitor=${name},${width}x${height}@${refreshRate},${xOffset}x${yOffset},${scaling}";

  mkMonitors = monitors: strings.concatStringsSep "\n" (builtins.map mkMonitor monitors);
  firstMonitor = builtins.elemAt cfg.monitors 0;
in
{
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.extraConfig = strings.concatStringsSep "\n" [
      ''
      # Palette
      source = ${theme.hyprland.palette}
      ''

      # --- #

      ''
      # See https://wiki.hyprland.org/Configuring/Monitors/
      ${mkMonitors cfg.monitors}
      ''

      (strings.optionalString cfg.mirrorFirstMonitor
      ''
      monitor=,preferred,auto,1,mirror,${(builtins.elemAt cfg.monitors 0).name}
      ''
      )

      # --- #

      ''
      exec-once = ${getExe pkgs.swww} init
      exec-once = sleep 5; ${getExe pkgs.swww} img ${cfg.wallpaper}
      ''

      # --- #

      ''

      $mainMod = SUPER
      $mainModKey = SUPER_L


      # See https://wiki.hyprland.org/Configuring/Keywords/ for more

      # Execute your favorite apps at launch
      exec-once = swayosd --max-volume 150

      exec-once = hyprctl setcursor ${theme.gtk.cursorTheme.name} 24
      ''

      # --- #

      (strings.optionalString config.hellebore.desktop-environment.hyprland.logout.enable
      ''
      bind = $mainMod, L, exec, ${config.hellebore.desktop-environment.hyprland.logout.bin}
      '')

      # ----------------
      # ---Workspaces---
      # ----------------
      ''
      workspace = 1,default:true,persistent:true
      ''

      (strings.optionalString config.hellebore.desktop-environment.browsers.enable
      ''
      exec-once = [workspace 1] ${getExe pkgs.firefox}
      ''
      )

      (strings.optionalString config.hellebore.shell.emulator.enable
      ''
      exec-once = [workspace 1] ${config.hellebore.shell.emulator.bin}
      bind = $mainMod, Q, exec, ${config.hellebore.shell.emulator.bin}
      '')

      (strings.optionalString config.hellebore.tools.office.enable
      ''
      workspace = 2,persistent:true
      exec-once = [workspace 2] obsidian
      ''
      )

      (strings.optionalString config.hellebore.tools.discord.enable
      ''
      workspace = 3,persistent:true
      exec-once = ${getExe config.hellebore.tools.discord.finalPackage}
      ${mkWindowrulev2 "class:(discord)" [
        "workspace 3 silent"
        "noinitialfocus"
      ]}
      '')

      (strings.optionalString config.hellebore.desktop-environment.mail.enable
      ''
      workspace = 4,persistent:true
      ${mkWindowrulev2 "class:(evolution)" [
        "workspace 4 silent"
      ]}
      exec-once = ${config.hellebore.desktop-environment.mail.bin}
      ''
      )

      (strings.optionalString osConfig.hellebore.games.enable
      ''
      workspace = 5,persistent:true
      ${mkWindowrulev2 "class:(steam)" [
        "workspace 5 silent"
      ]}
      ${mkWindowrulev2 "class:(.gamescope-wrapped)" [
        "workspace 5"
        "idleinhibit"
      ]}
      ${mkWindowrulev2 "class:(lutris)" [
        "workspace 5"
      ]}
      ${mkWindowrulev2 "class:^.*(Cartridges).*$" [
        "workspace 5 silent"
      ]}
      ${mkWindowrulev2 "class:(steam_app_).*" [
        "workspace 5"
        "idleinhibit"
      ]}
      exec-once = cartridges
      exec-once = steam -silent
      ''
      )

      (strings.optionalString osConfig.hellebore.vm.enable
      ''
      workspace = 6,persistent:true
      ${mkWindowrulev2 "title:(${osConfig.hellebore.vm.name})class:(looking-glass-client)" [
        "fullscreen"
        "idleinhibit always"
        "workspace 6"
      ]}

      bind = $mainMod, W, exec, start-vm --resolution=${toString firstMonitor.width}x${toString firstMonitor.height} -Fi
      ''
      )


      # ----------------

      (strings.optionalString config.hellebore.desktop-environment.hyprland.applications-launcher.enable
        ''
        bind = $mainMod, R, exec, ${config.hellebore.desktop-environment.hyprland.applications-launcher.command}
        ''
      )

      (strings.optionalString config.hellebore.desktop-environment.i18n.enable
      ''
      bind = $mainMod, I, exec, fcitx5-remote -t
      '')

      # --- #
      ''
      # Some default env vars.
      env = XCURSOR_SIZE,24

      # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
      input {
          kb_layout = ${cfg.input.kbLayout}
          kb_variant = ${cfg.input.kbVariant}

          follow_mouse = 1

          touchpad {
              natural_scroll = ${toString cfg.input.touchpad.naturalScroll}
              tap-to-click = ${toString cfg.input.touchpad.tapToClick}
          }

          sensitivity = ${toString cfg.input.mouse.sensitivity} # -1.0 - 1.0, 0 means no modification.
      }

      general {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          gaps_in = 5
          gaps_out = 20
          border_size = 2
          col.active_border = $mauve $sapphire 45deg
          col.inactive_border = $surface0 0x80$mauveAlpha 45deg

          layout = dwindle
      }

      decoration {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          rounding = 10

          blur {
            enabled = true
            size = 3
            passes = 1
            new_optimizations = true
          }

          drop_shadow = true
          shadow_range = 4
          shadow_render_power = 3
          col.shadow = $crust
      }

      animations {
          enabled = true

          # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

          bezier = easeOutCubic, .33, 1, .68, 1
          bezier = easeInOutSine, .37, 0, .63, 1

          animation = windows, 1, 7, easeOutCubic
          animation = windowsOut, 1, 7, easeOutCubic, popin 80%
          animation = windowsIn, 1, 7, easeOutCubic, popin 80%
          animation = border, 1, 3, easeInOutSine
          animation = borderangle, 1, 300, easeInOutSine, loop
          animation = fade, 1, 7, default
          animation = workspaces, 1, 3, easeInOutSine
      }

      dwindle {
          # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
          pseudotile = true # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = true # you probably want this
      }

      gestures {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          workspace_swipe = false
      }

      # See https://wiki.hyprland.org/Configuring/Keywords/ for more

      # Multimedia Keys
      bindle =, XF86AudioRaiseVolume, exec, ${getExe pkgs.volume-brightness} -v 1.5 @DEFAULT_AUDIO_SINK@ 5%+
      bindle =, XF86AudioLowerVolume, exec, ${getExe pkgs.volume-brightness} -v 1.5 @DEFAULT_AUDIO_SINK@ 5%-
      bindl =, XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bindl =, XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
      bindr = CAPS, Caps_Lock, exec, swayosd --caps-lock
      bindle =, XF86MonBrightnessUp, exec, ${getExe pkgs.volume-brightness} -b 5%+
      bindle =, XF86MonBrightnessDown, exec, ${getExe pkgs.volume-brightness} -b 5%-
      bind = , code:107, exec, pkill grimblast; grimblast --notify copysave area ~/Pictures/Screenshots/$(date +%F:%H:%M:%S).png
      bind = $mainMod, code:107, exec, pkill grimblast; grimblast --notify copysave screen ~/Pictures/Screenshots/$(date +%F:%H:%M:%S).png

      # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
      bind = $mainMod, C, killactive,
      bind = $mainMod, E, exec, nemo
      bind = $mainMod, V, togglefloating,
      bind = $mainMod, P, exec, hyprpicker -a

      # Window manipulations
      bind = $mainMod, J, togglesplit, # dwindle
      bind = $mainMod, M, fullscreen, 1 # Maximize window
      bind = $mainMod, F, fullscreen, 0 # Fullscreen window

      # Move focus with mainMod + arrow keys
      bind = $mainMod, left, movefocus, l
      bind = $mainMod, right, movefocus, r
      bind = $mainMod, up, movefocus, u
      bind = $mainMod, down, movefocus, d

      # Move windows with mainMod ALT + arrow keys
      bind = $mainMod ALT, left, movewindow, l
      bind = $mainMod ALT, right, movewindow, r
      bind = $mainMod ALT, up, movewindow, u
      bind = $mainMod ALT, down, movewindow, d

      # Switch to next/previous workspace
      bind = $mainMod SHIFT, right, workspace, e+1
      bind = $mainMod SHIFT, left, workspace, e-1
      bind = $mainMod CTRL, right, movetoworkspace, +1
      bind = $mainMod CTRL, left, movetoworkspace, -1

      # Switch workspaces with mainMod + F[1-10]
      ${strings.concatStringsSep "\n" (
          lists.map
          (item: "bind = $mainMod, F${toString item}, workspace, ${toString item}")
          (range 1 10)
        )
      }

      # Move active window to a workspace with mainMod + CONTROL + F[1-10]
      ${strings.concatStringsSep "\n" (
          lists.map
          (item: "bind = $mainMod CONTROL, F${toString item}, movetoworkspace, ${toString item}")
          (range 1 10)
        )
      }

      # Scroll through existing workspaces with mainMod + scroll
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow
      ''
      ];
    };
}

