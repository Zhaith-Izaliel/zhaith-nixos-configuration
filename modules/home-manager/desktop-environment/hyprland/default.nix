{ osConfig, config, theme, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.desktop-environment.hyprland;

  isNvidia =
    elem "nvidia" osConfig.services.xserver.videoDrivers
    && osConfig.hardware.nvidia.prime.offload.enable
      || osConfig.hardware.nvidia.prime.reverseSync.enable;
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

    monitors = mkOption {
      type = types.listOf monitorType;
      default = [];
      description = "Primary screen resolution.";
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
        default = osConfig.hellebore.locale.keyboard.defaultLayout;
        description = "Keyboard layout for Hyprland.";
      };
      kbVariant = mkOption {
        type = types.str;
        default = osConfig.hellebore.locale.keyboard.defaultVariant;
        description = "Keyboard variant for Hyprland.";
      };

      mouse = {
        sensitivity = mkOption {
          type = types.numbers.between -1.0 1.0;
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
        assertion = cfg.enable -> osConfig.programs.hyprland.enable;
        message = "Hyprland must be enabled in your system configuration";
      }
      {
        assertion = cfg.enable -> osConfig.programs.hyprland.xwayland.enable;
        message = "Hyprland XWayland must be enabled in your system configuration";
      }
    ];

    home.sessionVariables = {
      GDK_BACKEND = "wayland,x11";
      QT_QPA_PLATFORM = "wayland;xcb";
      #SDL_VIDEODRIVER = "x11";
      CLUTTER_BACKEND = "wayland";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
      WLR_NO_HARDWARE_CURSORS = "1";
    };


    home.packages = with pkgs; [
      swww
      swayosd
      wl-clipboard
      power-management
      hyprpicker
      grimblast
      volume-brightness
    ] ++ theme.gtk.packages;

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
      enableNvidiaPatches = isNvidia;
      systemd.enable = true;
    };
  };
}

