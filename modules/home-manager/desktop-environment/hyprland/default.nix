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
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> os-config.programs.hyprland.enable;
        message = "Hyprland must be enabled in your system configuration";
      }
      {
        assertion = cfg.enable -> os-config.programs.hyprland.xwayland.enable;
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
