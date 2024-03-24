{
  os-config,
  config,
  lib,
  pkgs,
  extra-types,
  ...
}: let
  inherit (lib) types mkOption mkEnableOption mkIf;
  cfg = config.hellebore.desktop-environment.hyprland;
  theme = config.hellebore.theme.themes.${cfg.theme};
  extraRulesType = types.submodule {
    options = {
      rules = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [];
        description = "Defines the rules to apply to the game window";
      };

      regex = mkOption {
        type = types.nonEmptyStr;
        default = "";
        description = "Defines the regular expression used to find the window or layer on Hyprland. See: https://wiki.hyprland.org/Configuring/Window-Rules/#window-rules-v2 and https://wiki.hyprland.org/Configuring/Window-Rules/#layer-rules";
      };
    };
  };
in {
  imports = [
    ./config.nix
  ];

  options.hellebore.desktop-environment.hyprland = {
    enable = mkEnableOption "Hellebore Hyprland configuration";

    monitors =
      extra-types.monitors
      // {
        default = config.hellebore.monitors;
      };

    layout = mkOption {
      type = types.enum ["dwindle" "master"];
      description = "Defines the layout used in Hyprland.";
      default = "dwindle";
    };

    theme = extra-types.theme.name {
      default = config.hellebore.theme.name;
      description = "Defines the theme applied to Hyprland and GTK/QT based
      applications.";
    };

    mirrorFirstMonitor =
      mkEnableOption null
      // {
        description = "Allow Hyprland to mirror the first monitor defined in its
      monitors list when connecting an unknown monitor.";
      };

    wallpaper = mkOption {
      type = types.path;
      default = ../../../../assets/images/wallpaper/wallpaper.png;
      description = "Set the wallpaper.";
    };

    extraWindowRules = mkOption {
      type = types.listOf extraRulesType;
      default = [];
      description = "Defines a list of extra rules for windows to be applied.";
    };

    extraLayerRules = mkOption {
      type = types.listOf extraRulesType;
      default = [];
      description = "Defines a list of extra rules for windows to be applied.";
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
    ];

    home.sessionVariables = {
      GDK_BACKEND = "wayland,x11";
      QT_QPA_PLATFORM = "wayland;xcb";
      CLUTTER_BACKEND = "wayland";
      # XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      # XDG_SESSION_DESKTOP = "Hyprland";
      WLR_NO_HARDWARE_CURSORS = "1";
    };

    home.packages = with pkgs;
      [
        swww
        swayosd
        power-management
        hyprpicker
        grimblast
        volume-brightness
        screenshot
        power-management
        gnome.gnome-themes-extra # Add default Gnome theme as well for Adwaita
      ]
      ++ theme.gtk.packages;

    gtk = {
      enable = true;
      inherit (theme.gtk) theme cursorTheme iconTheme;

      font = {
        inherit (theme.gtk.font) name package;
        size = config.hellebore.font.size;
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      package = os-config.programs.hyprland.package;
      xwayland.enable = true;
      systemd.enable = true;
    };
  };
}
