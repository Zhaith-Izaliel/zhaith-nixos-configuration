{ os-config, config, lib, pkgs, extra-types, ... }:


let
  inherit (lib) mkIf mkOption mkEnableOption elemAt types getExe recursiveUpdate;
  cfg = config.hellebore.desktop-environment.status-bar;
  theme = config.hellebore.theme.themes.${config.hellebore.theme.name}.waybar;
  modulesToUse = [

  ];
in
{
  options.hellebore.desktop-environment.status-bar = {
    enable = mkEnableOption "Hellebore Waybar configuration";

    font = extra-types.font {
      size = config.hellebore.font.size;
      name = "Fira Code Nerd Font Mono";
      sizeDescription = "Set the status bar font size.";
      nameDescription = "Set the status bar font family.";
    };

    backlight-device = mkOption {
      type = types.nonEmptyStr;
      default = "";
      description = "Defines the backlight device to use.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> config.wayland.windowManager.hyprland.enable;
        message = "Waybar depends on Hyprland for its modules. Please enable
        Hyprland in your configuration";
      }
    ];

    home.packages = with pkgs; [
      sutils
      libappindicator-gtk3
      brightnessctl
      wttrbar
    ];

    systemd.user.targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = [ "graphical-session-pre.target" ];
      };
    };

    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        target = "hyprland-session.target";
      };

      settings = recursiveUpdate theme.settings {
        mainBar = {
          output = (elemAt config.hellebore.monitors 0).name;

          "custom/weather" = {
            tooltip = true;
            interval = 3600;
            exec = "${getExe pkgs.wttrbar} --custom-indicator'{ICON}{temp_C}°C({FeelsLikeC}°C)'";
            return-type = "json";
          };

          bluetooth = {
            on-click = "${getExe pkgs.toggle-bluetooth}";
            on-click-right = "${pkgs.blueberry}/bin/blueberry";
          };

          backlight = {
            device = cfg.backlight-device;
            on-scroll-up = "${lib.getExe pkgs.volume-brightness} -b 1%+";
            on-scroll-down = "${lib.getExe pkgs.volume-brightness} -b 1%-";
          };

          battery = {
            states = {
              good = 95;
              warning = 30;
              critical = 20;
            };
          };

          clock = {
            timezone = os-config.time.timeZone;
          };

          wireplumber = {
            on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            on-click-right = "${lib.getExe pkgs.pavucontrol}";
            on-scroll-up = "${lib.getExe pkgs.volume-brightness} -v 1.5 @DEFAULT_AUDIO_SINK@ 1%+";
            on-scroll-down = "${lib.getExe pkgs.volume-brightness} -v 1.5 @DEFAULT_AUDIO_SINK@ 1%-";
          };
        };
      };

      style = ''
      * {
        font-size: ${toString cfg.font.size}pt;
        font-family: '${cfg.font.name}';
      }
      '' + theme.style;
    };
  };
}

