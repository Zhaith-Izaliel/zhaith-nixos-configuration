{
  os-config,
  config,
  lib,
  pkgs,
  extra-types,
  ...
}: let
  inherit
    (lib)
    types
    mkOption
    mkEnableOption
    mkIf
    mkPackageOption
    optional
    ;

  cfg = config.hellebore.desktop-environment.hyprland;
  theme = config.hellebore.theme.themes.${cfg.theme};

  finalPackage = cfg.package.override {enableXWayland = true;};

  extraBindsType = types.submodule {
    options = {
      binds = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [];
        description = "The actual binds to add. See https://wiki.hyprland.org/Configuring/Binds";
      };

      flags = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [];
        description = "Defines the flags applied to the bind. See https://wiki.hyprland.org/Configuring/Binds/#bind-flags";
      };
    };
  };

  extraWindowAndLayerRulesType = types.submodule {
    options = {
      rules = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [];
        description = "Defines the rules to apply to the window or layer.";
      };

      regex = mkOption {
        type = types.nonEmptyStr;
        default = "";
        description = "Defines the regular expression used to find the window or layer on Hyprland. See https://wiki.hyprland.org/Configuring/Window-Rules/#window-rules-v2 and https://wiki.hyprland.org/Configuring/Window-Rules/#layer-rules";
      };
    };
  };

  extraWorkspaceRulesType = types.submodule {
    options = {
      rules = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [];
        description = "Defines the rules to apply to the workspace.";
      };

      selector = mkOption {
        type = types.nonEmptyStr;
        default = "";
        description = "Defines the selector used to select workspace(s) to apply these rules. See https://wiki.hyprland.org/Configuring/Workspace-Rules/#workspace-selectors";
      };
    };
  };

  pwaType = types.attrsOf (types.submodule {
    options = {
      enable =
        mkEnableOption "this particular Progressive Web App"
        // {
          default = true;
        };

      id = mkOption {
        type = types.nonEmptyStr;
        default = "";
        description = "The ID of the PWA used by `pkgs.firefoxpwa`.";
      };

      execRules = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [];
        description = "A list of exec rules to add to the exec-once call.";
      };

      windowRules = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [];
        description = "The window rules to apply on the PWA.";
      };
    };
  });
in {
  imports = [
    ./config.nix
  ];

  options.hellebore.desktop-environment.hyprland = {
    enable = mkEnableOption "Hellebore Hyprland configuration";

    package =
      (mkPackageOption pkgs "hyprland" {})
      // {
        default = os-config.programs.hyprland.package;
      };

    monitors =
      extra-types.monitors
      // {
        default = config.hellebore.monitors;
      };

    layout = mkOption {
      type = types.enum ["dwindle" "master" "scroller"];
      description = "Defines the layout used in Hyprland.";
      default =
        if cfg.hyprscroller.enable
        then "scroller"
        else "dwindle";
    };

    theme = extra-types.theme.name {
      default = config.hellebore.theme.name;
      description = "Defines the theme applied to Hyprland and GTK/QT based
      applications.";
    };

    cursor =
      (extra-types.cursor {
        name = theme.gtk.cursorTheme.name;
        size = config.hellebore.cursor.size;
        nameDescription = "Defines the name of the cursor theme to use.";
        sizeDescription = "Defines the size of the cursor theme to use.";
      })
      // {
        hardwareCursors =
          (mkEnableOption "hardware cursors. Off by default")
          // {
            default = false;
          };
      };

    wallpaper = mkOption {
      type = types.path;
      default = ../../../../assets/images/wallpaper/wallpaper.png;
      description = "Set the wallpaper.";
    };

    extraExec = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Defines a list of extra `exec` rules to be applied.";
    };

    extraExecOnce = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Defines a list of extra `exec-once` rules to be applied.";
    };

    extraWindowRules = mkOption {
      type = types.listOf extraWindowAndLayerRulesType;
      default = [];
      description = "Defines a list of extra rules for windows to be applied.";
    };

    extraLayerRules = mkOption {
      type = types.listOf extraWindowAndLayerRulesType;
      default = [];
      description = "Defines a list of extra rules for layers to be applied.";
    };

    extraWorkspaceRules = mkOption {
      type = types.listOf extraWorkspaceRulesType;
      default = [];
      description = "Defines a list of extra rules for workspaces to be applied.";
    };

    extraBinds = mkOption {
      type = types.listOf extraBindsType;
      default = [];
      description = "Defines a list of extra binds to add, with their own flags.";
    };

    extraUnbinds = mkOption {
      type = types.listOf types.nonEmptyStr;
      default = [];
      description = "Defines a list of extra unbinds to remove default bindings.";
    };

    misc = {
      middleClickPaste = mkEnableOption "middle click paste";
    };

    bugFixes = {
      cursorRenderingInXWaylandApps =
        (mkEnableOption null)
        // {
          description = "Fix invisible cursors in some XWayland applications. Should be kept until https://github.com/hyprwm/Hyprland/issues/7335 is fixed upstream.";
        };
    };

    progressiveWebApps = mkOption {
      type = pwaType;
      default = {};
      description = "Defines all progressive web-apps to be run on startup as well as their own window rules.";
    };

    input = {
      keyboard = extra-types.keyboard {
        inherit (config.hellebore.locale.keyboard) layout variant;
      };

      mouse = {
        sensitivity = mkOption {
          type = types.numbers.between (-1.0) 1.0;
          default = 0;
          description = "Defines the mouse sensitivity in Hyprland (between -1.0
          and 1.0 inclusive)";
        };

        scrollFactor = mkOption {
          type = types.float;
          default = 1.0;
          description = "Multiplier added to scroll movement for external mice. Note that there is a separate setting for touchpad.";
        };
      };

      touchpad = {
        naturalScroll = mkOption {
          type = types.bool;
          default = true;
          description = "Enable touchpad's natural scroll.";
        };

        scrollFactor = mkOption {
          type = types.float;
          default = 1.0;
          description = "Multiplier added to scroll movement for external mice. Note that there is a separate setting for external mice.";
        };

        tapToClick = mkOption {
          type = types.bool;
          default = true;
          description = "Tapping the touchpad throw a left click.";
        };
      };

      touchscreen = {
        enable = mkEnableOption "support for touchscreens using Hyprgrass";

        package = mkPackageOption pkgs ["hyprlandPlugins" "hyprgrass"] {};

        sensitivity = mkOption {
          type = types.float;
          default = 1.0;
          description = "Defines the touch sensitivity.";
        };

        workspaceSwipeFingers = mkOption {
          default = 3;
          type = types.ints.unsigned;
          description = "The number of fingers to switch workspace when swiping. Must be greater or equal to 3.";
        };

        longPressDelay = mkOption {
          default = 400;
          type = types.ints.unsigned;
          description = "The time required for a press to be long, in milliseconds.";
        };

        resizeWindowsByLongPressing =
          (mkEnableOption "allowing resizing windows on long pressing their borders and gap")
          // {
            default = true;
          };

        edgeMargin = mkOption {
          type = types.ints.unsigned;
          default = 10;
          description = "The distance from the physical edge of the screen that is considered an edge";
        };
      };
    };

    hyprscroller = {
      enable = mkEnableOption "Hyprscroller for Hyprland. Hyprland needs to be enabled for Hyprscroller to work";

      package = mkPackageOption pkgs ["hyprlandPlugins" "hyprscroller"] {};
    };

    picture-in-picture = {
      enable = mkEnableOption "Firefox's Picture-in-Picture support";

      position = mkOption {
        type = types.enum [
          "bottom-left"
          "center-left"
          "top-left"
          "bottom-center"
          "top-center"
          "bottom-right"
          "center-right"
          "top-right"
        ];
        default = "bottom-left";
        description = "Defines the initial position of the Picture-in-Picture window.";
      };

      keymaps = {
        enable = mkEnableOption "keymaps for moving picture-in-picture floating window";
      };
    };

    switches = {
      lid = {
        enable = mkEnableOption "Lid Switch";

        name = mkOption {
          default = "Lid Switch";
          type = types.nonEmptyStr;
          description = "The name of the lid switch.";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = os-config.programs.hyprland.enable;
        message = "Hyprland must be enabled in your system configuration";
      }
      {
        assertion = os-config.programs.hyprland.xwayland.enable;
        message = "Hyprland XWayland must be enabled in your system configuration";
      }
      {
        assertion = cfg.input.touchscreen.enable -> cfg.input.touchscreen.workspaceSwipeFingers >= 3;
        message = "You need at least 3 fingers to swipe workspaces with a touchscreen.";
      }
      {
        assertion = cfg.input.touchscreen.enable -> os-config.hellebore.hardware.touchscreen.enable;
        message = "You need to enable touchscreen support on the OS side with `hellebore.hardware.touchscreen.enable`.";
      }
      {
        assertion = cfg.layout == "scroller" -> cfg.hyprscroller.enable;
        message = "You need to enable Hyprscroller to use the scroller layout.";
      }
    ];

    home.sessionVariables = {
      # GDK_BACKEND = "wayland,x11";
      # QT_QPA_PLATFORM = "wayland;xcb";
      # CLUTTER_BACKEND = "wayland";
      # XDG_CURRENT_DESKTOP = "Hyprland";
      # XDG_SESSION_TYPE = "wayland";
      # XDG_SESSION_DESKTOP = "Hyprland";
      # ADW_DISABLE_PORTAL = "1";
    };

    home.packages =
      (with pkgs; [
        swww
        swayosd
        power-management
        hyprpicker
        grimblast
        volume-brightness
        screenshot
        power-management
        gnome-themes-extra # Add default Gnome theme as well for Adwaita
      ])
      ++ theme.gtk.packages;

    gtk = {
      enable = true;
      inherit (theme.gtk) theme cursorTheme iconTheme;

      font = {
        inherit (theme.gtk.font) name package;
        size = config.hellebore.font.size;
      };

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };

      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };

    wayland.windowManager.hyprland = {
      package = finalPackage;
      enable = true;
      xwayland.enable = true;
      systemd.enable = true;
      plugins =
        optional cfg.input.touchscreen.enable cfg.input.touchscreen.package
        ++ optional cfg.hyprscroller.enable cfg.hyprscroller.package;
    };
  };
}
