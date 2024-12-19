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

  obsSceneBindsType = types.submodule {
    options = {
      scene = mkOption {
        type = types.nonEmptyStr;
        default = "";
        description = "The name of the scene in OBS to switch to with the actual keybind.";
      };

      keys = mkOption {
        type = types.nonEmptyStr;
        default = "";
        description = "The actual keys to bind. See https://wiki.hyprland.org/Configuring/Binds";
      };
    };
  };

  extraBindsType = types.submodule {
    options = {
      bind = mkOption {
        type = types.nonEmptyStr;
        default = "";
        description = "The actual bind to add. See https://wiki.hyprland.org/Configuring/Binds";
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

      font = extra-types.font {
        name = config.hellebore.font.name;
        nameDescription = "Defines the font family used for Hyprland.";
        size = config.hellebore.font.size;
        sizeDescription = "Defines the font size used for Hyprland.";
      };
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

    submaps = {
      enabled = mkOption {
        type = types.bool;
        default = builtins.any (item: item) [
          cfg.submaps.obs.enable
          cfg.hyprscroller.enable
          cfg.submaps.discord.enable
        ];
        description = "Read-only option to know if any submap is enabled";
        readOnly = true;
      };

      obs = {
        enable =
          mkEnableOption "OBS Studio submap"
          // {
            default = config.hellebore.multimedia.obs-studio.cli.enable;
          };

        sceneBinds = mkOption {
          type = types.listOf obsSceneBindsType;
          default = [];
          description = "Extra binds to switch between scenes. Keep in mind this is a submap so the binds can be minimal (i.e. only one key).";
        };
      };

      discord.enable =
        mkEnableOption "Discord submap"
        // {
          default = config.hellebore.tools.discord.enable;
        };
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

      settings = {
        defaultColumnWidth = mkOption {
          type = types.enum [
            "oneeighth"
            "onesixth"
            "onefourth"
            "onethird"
            "threeeighths"
            "onehalf"
            "fiveeighths"
            "twothirds"
            "threequarters"
            "fivesixths"
            "seveneighths"
            "maximized"
            "floating"
          ];
          default = "onehalf";
          description = "Determines the width of new columns in row mode.";
        };

        defaultWindowHeight = mkOption {
          type = types.enum [
            "oneeighth"
            "onesixth"
            "onefourth"
            "onethird"
            "threeeighths"
            "onehalf"
            "fiveeighths"
            "twothirds"
            "threequarters"
            "fivesixths"
            "seveneighths"
            "one"
          ];
          default = "one";
          description = "Determines the height of new windows.";
        };

        focusWrap =
          (mkEnableOption null)
          // {
            default = true;
            description = "Determines whether focus will wrap when at the first or last window of a row/column.";
          };

        centerRowIfSpaceAvailable =
          (mkEnableOption null)
          // {
            description = "If there is empty space in the viewport, the row will be centered, leaving the same amount of empty space on each side (respecting `gaps_out`).";
          };

        overviewScaleContent =
          (mkEnableOption null)
          // {
            default = true;
            description = "Scales the content of the windows in overview mode, like GNOME/MacOS/Windows overview mode.";
          };

        columnWidths = mkOption {
          type = types.listOf (types.enum [
            "oneeighth"
            "onesixth"
            "onefourth"
            "onethird"
            "threeeighths"
            "onehalf"
            "fiveeighths"
            "twothirds"
            "threequarters"
            "fivesixths"
            "seveneighths"
            "one"
          ]);
          default = [
            "onehalf"
            "twothirds"
            "onethird"
          ];
          description = "Determines the set of column widths hyprscroller will cycle through when resizing the width of a column in row mode.";
        };

        windowHeights = mkOption {
          type = types.listOf (types.enum [
            "oneeighth"
            "onesixth"
            "onefourth"
            "onethird"
            "threeeighths"
            "onehalf"
            "fiveeighths"
            "twothirds"
            "threequarters"
            "fivesixths"
            "seveneighths"
            "one"
          ]);
          default = [
            "one"
            "onethird"
            "onehalf"
            "twothirds"
          ];
          description = "Determines the set of window heights hyprscroller will cycle through when resizing the height of a window in column mode.";
        };

        jumpLabels = {
          scale = mkOption {
            type = types.numbers.between 0.1 1.0;
            default = 0.1;
            description = "jump labels will be centered in each window, and this parameter scales their size.";
          };

          keys = mkOption {
            type = types.listOf types.nonEmptyStr;
            default = [
              "a"
              "z"
              "e"
              "r"
              "t"
              "y"
            ];
            description = "It is a string with the keys that will be used for the labels. For example, 1234 means labels will show a unique combination of 1, 2, 3 and 4. The more keys you set on this option, the shorter the combination of key presses to reach any window, but some times, reaching for those keys can be slower.";
          };
        };

        gestures = {
          scroll = {
            enable =
              (mkEnableOption "touchpad gestures for scrolling (changing focus)")
              // {
                default = true;
              };

            fingers = mkOption {
              type = types.ints.unsigned;
              default = 3;
              description = "Defines the number of fingers used to swipe when scrolling.";
            };

            distance = mkOption {
              type = types.ints.unsigned;
              default = 60;
              description = "Delta generated by swiping to move focus one window. It is like a sensitivity value; the smaller, the more sensitive scrolling will be to swipes.";
            };
          };

          overview = {
            enable =
              (mkEnableOption "touchpad gestures to call overview mode and workspace switching.")
              // {
                default = true;
              };

            fingers = mkOption {
              type = types.ints.unsigned;
              default = 4;
              description = "Defines the number of fingers used to swipe for overview or changing workspace.";
            };

            distance = mkOption {
              type = types.ints.unsigned;
              default = 5;
              description = "Delta generated by swiping to call overview mode or change workspace. It is like a sensitivity value; the smaller, the easier it will be to trigger the command. Each swipe triggers it only once, regardless of the length or the swipe.";
            };
          };

          workspaceSwitchPrefix = mkOption {
            type = types.str;
            default = "";
            description = ''
              It is the prefix used when calling the dispatcher to switch to a different workspace. Read Workspaces in the Hyprland wiki to understand in detail what each prefix means.

              The prefix value will be concatenated to +1 or -1 to change workspace when swiping to one side or the other.'';
          };
        };
      };
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

      enableBinds = mkEnableOption "binds for moving picture-in-picture floating window";

      ratio = mkOption {
        type = types.ints.unsigned;
        default = 8;
        description = "The ratio used to calculate the picture-in-picture window size. It is the divider for the monitor height and size.";
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
      {
        assertion = cfg.submaps.obs.enable -> config.hellebore.multimedia.obs-studio.cli.enable;
        message = "You need to enable the OBS CLI through `config.hellebore.multimedia.obs-studio.cli.enable` for the OBS Studio submap to work.";
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
