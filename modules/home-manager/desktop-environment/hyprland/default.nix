{ osConfig, config, theme, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.desktop-environment.hyprland;
  mkWindowrulev2 = window: rules: (builtins.concatStringsSep "\n" (map (rule: "windowrulev2=${rule},${window}") rules));
  monitorType = types.submodule {
    options = {
      name = mkOption { type = types.str; };
      width = mkOption { type =  types.int; };
      height = mkOption { type = types.int; };
      refreshRate = mkOption { type = types.int; };
      xOffset = mkOption { type = types.int; };
      yOffset = mkOption { type = types.int; };
      scaling = mkOption { type = types.float; };
    };
  };
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

in
{
  imports = [
    ./logout.nix
    ./lockscreen.nix
    ./notifications.nix
    ./applications-launcher
    ./status-bar
  ];

  options.hellebore.desktop-environment.hyprland = {
    enable = mkEnableOption "Hellebore Hyprland configuration";

    monitors = mkOption {
      type = types.listOf monitorType;
      default = "1920x1080";
      description = "Primary screen resolution.";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.hyprland;
      description = "Override default Hyprland package";
    };

    wallpaper = mkOption {
      type = types.path;
      default = ../../../../assets/images/wallpaper/wallpaper.png;
      description = "Set the wallpaper.";
    };

    input = {
      kbLayout = mkOption {
        type = types.str;
        default = "fr";
        description = "Keyboard layout for Hyprland.";
      };
      kbVariant = mkOption {
        type = types.str;
        default = "oss_latin9";
        description = "Keyboard variant for Hyprland.";
      };

      touchpad = {
        naturalScroll = mkOption {
          type = types.bool;
          default = true;
          description = "Enable touchpad's natural scroll.";
        };

        tapToClick = mkOption {
          type = types.bool;
          default = true;
          description = "Tapping the touchpad throw a left click.";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> osConfig.programs.hyprland.enable;
        message = "Hyprland must be enabled in your system configuration";
      }
      {
        assertion = cfg.enable -> osConfig.programs.hyprland.xwayland.enable;
        message = "Hyprland XWayland must be enabled in your system configuration";
      }
    ];

    home.packages = with pkgs; [
      glib
      swww
      swayosd
      wl-clipboard
      power-management
      hyprpicker
      grimblast
      volume-brightness
    ];

    gtk = {
      enable = true;
      inherit (theme.gtk) theme cursorTheme iconTheme;

      font = {
        inherit (theme.gtk.font) name package;
        size = config.hellebore.fontSize;
      };

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };

      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      package = cfg.package;
      xwayland.enable = true;
      enableNvidiaPatches = osConfig.hardware.nvidia.enable;
      systemdIntegration = true;
      recommendedEnvironment = true;
      extraConfig = strings.concatStringsSep "\n" [
      ''
      # Palette
      source = ${theme.hyprland.palette}
      ''

      # --- #

      ''
      # See https://wiki.hyprland.org/Configuring/Monitors/
      ${mkMonitors cfg.monitors}
      ''

      # --- #

      ''
      exec-once = gsettings set org.gnome.desktop.interface gtk-theme '${theme.gtk.theme.name}'
      exec-once = gsettings set org.gnome.desktop.interface icon-theme '${theme.gtk.iconTheme.name}'
      exec-once = gsettings set org.gnome.desktop.interface cursor-theme '${theme.gtk.cursorTheme.name}'
      exec-once = gsettings set org.gnome.desktop.interface font-name '${theme.gtk.font.name}'
      ''

      # --- #

      ''
      exec-once = swww init
      exec-once = sleep 5; swww img ${cfg.wallpaper}
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

      (strings.optionalString config.hellebore.tools.discord.enable
      ''
      exec-once = ${getExe config.hellebore.tools.discord.package}
      ${mkWindowrulev2 "class:(discord)" [ "workspace 3" ]}
      '')

      # --- #

      (strings.optionalString config.hellebore.desktop-environment.hyprland.logout.enable
      ''
      bind = $mainMod, L, exec, ${config.hellebore.desktop-environment.hyprland.logout.bin}
      '')

      # --- #

      (strings.optionalString config.hellebore.desktop-environment.mail.enable
      "exec-once = [workspace 4] ${config.hellebore.desktop-environment.mail.bin}")

      # --- #

      (strings.optionalString config.hellebore.tools.office.enable
      "exec-once = [workspace 2] obsidian")

      # --- #

      (strings.optionalString config.hellebore.shell.emulator.enable
      ''
      exec-once = [workspace 1] ${config.hellebore.shell.emulator.bin}
      bind = $mainMod, Q, exec, ${config.hellebore.shell.emulator.bin}
      '')

      # --- #

      (strings.optionalString osConfig.hellebore.vm.enable
        ''
        ${mkWindowrulev2 "title:(Luminous-Rafflesia)class:(looking-glass-client)" [
          "fullscreen"
        ]}
        ${mkWindowrulev2 "title:(Luminous-Rafflesia),class:(looking-glass-client)"[
          "idleinhibit always"
        ]}
        bind = $mainMod, W, exec, [workspace empty] start-vm --resolution=2560x1440 -Fi
        ''
      )
      # --- #

      (strings.optionalString config.hellebore.desktop-environment.hyprland.applications-launcher.enable
        ''
        bind = $mainMod, R, exec, ${config.hellebore.desktop-environment.hyprland.applications-launcher.command}
        ''
      )


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

          sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
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
      bindle =, XF86AudioRaiseVolume, exec, volume-brightness -v 1.5 @DEFAULT_AUDIO_SINK@ 5%+
      bindle =, XF86AudioLowerVolume, exec, volume-brightness -v 1.5 @DEFAULT_AUDIO_SINK@ 5%-
      bindl =, XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bindl =, XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
      bindr = CAPS, Caps_Lock, exec, swayosd --caps-lock
      bindle =, XF86MonBrightnessUp, exec, volume-brightness -b 5%+
      bindle =, XF86MonBrightnessDown, exec, volume-brightness -b 5%-
      bind = , code:107, exec, grimblast --notify copysave area ~/Pictures/Screenshots/$(date +%F:%H:%M:%S).png
      bind = $mainMod, code:107, exec, grimblast --notify copysave screen ~/Pictures/Screenshots/$(date +%F:%H:%M:%S).png

      # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
      bind = $mainMod, C, killactive,
      bind = $mainMod, E, exec, nemo
      bind = $mainMod, V, togglefloating,
      bind = $mainMod, I, exec, fcitx5-remote -t
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

      # Switch workspaces with mainMod + [0-9]
      bind = $mainMod, F1, workspace, 1
      bind = $mainMod, F2, workspace, 2
      bind = $mainMod, F3, workspace, 3
      bind = $mainMod, F4, workspace, 4
      bind = $mainMod, F5, workspace, 5
      bind = $mainMod, F6, workspace, 6
      bind = $mainMod, F7, workspace, 7
      bind = $mainMod, F8, workspace, 8
      bind = $mainMod, F9, workspace, 9
      bind = $mainMod, F10, workspace, 10

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      bind = $mainMod SHIFT, F1, movetoworkspace, 1
      bind = $mainMod SHIFT, F2, movetoworkspace, 2
      bind = $mainMod SHIFT, F3, movetoworkspace, 3
      bind = $mainMod SHIFT, F4, movetoworkspace, 4
      bind = $mainMod SHIFT, F5, movetoworkspace, 5
      bind = $mainMod SHIFT, F6, movetoworkspace, 6
      bind = $mainMod SHIFT, F7, movetoworkspace, 7
      bind = $mainMod SHIFT, F8, movetoworkspace, 8
      bind = $mainMod SHIFT, F9, movetoworkspace, 9
      bind = $mainMod SHIFT, F10, movetoworkspace, 10

      # Scroll through existing workspaces with mainMod + scroll
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow
      ''
      ];
    };
  };
}

