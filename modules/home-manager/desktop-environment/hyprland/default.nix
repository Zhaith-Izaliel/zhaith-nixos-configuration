{ os-config, config, theme, lib, pkgs, extra-types, ... }:

let
  inherit (lib) types mkOption mkEnableOption mkIf;
  cfg = config.hellebore.desktop-environment.hyprland;
in
{
  imports = [
    ./config.nix
    ./logout.nix
    ./lockscreen.nix
    ./notifications.nix
    ./applications-launcher
    ./status-bar
    ./widget
  ];

  options.hellebore.desktop-environment.hyprland = {
    enable = mkEnableOption "Hellebore Hyprland configuration";

    monitors = extra-types.monitors // {
      default = config.hellebore.monitors;
    };

    mirrorFirstMonitor = mkEnableOption null // {
      description = "Allow Hyprland to mirror the first monitor defined in its
      monitors list when connecting an unknown monitor.";
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
        default = os-config.hellebore.locale.keyboard.defaultLayout;
        description = "Keyboard layout for Hyprland.";
      };
      kbVariant = mkOption {
        type = types.str;
        default = os-config.hellebore.locale.keyboard.defaultVariant;
        description = "Keyboard variant for Hyprland.";
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
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
      WLR_NO_HARDWARE_CURSORS = "1";
      ADW_DISABLE_PORTAL = "1";
    };


    home.packages = with pkgs; [
      swww
      swayosd
      wl-clipboard
      power-management
      hyprpicker
      grimblast
      volume-brightness
      screenshot
    ] ++ theme.gtk.packages;

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
      enable = true;
      package = cfg.package;
      xwayland.enable = true;
      # enableNvidiaPatches = os-config.programs.hyprland.enableNvidiaPatches;
      systemd.enable = true;
    };
  };
}

