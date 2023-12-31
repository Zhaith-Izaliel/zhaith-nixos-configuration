{ config, lib, theme, ... }:

with lib;
let
  cfg = config.hellebore.desktop-environment.hyprland.notifications;
in
{

  options.hellebore.desktop-environment.hyprland.notifications = {
    enable = mkEnableOption "Hellebore Dunst configuration";

    fontSize = mkOption {
      type = types.int;
      default = config.hellebore.fontSize;
      description = "Set the notifications client font size.";
    };
  };

  config = mkIf cfg.enable {
    services.dunst = {
      enable = true;
      inherit (theme.gtk) iconTheme;

      settings = {
        global = {
          corner_radius = 15;
          font = "${theme.gtk.font.name} ${toString cfg.fontSize}";
          frame_color = theme.colors.mauve;
          highlight = theme.colors.mauve;
          separator_color = "frame";
          width = 400;
          height = 400;
          progress_bar = true;
          enable_posix_regex = true;
        };

        urgency_low = {
          background = theme.colors.base;
          highlight = theme.colors.sapphire;
          foreground = theme.colors.text;
          frame_color = theme.colors.sapphire;
        };

        urgency_normal = {
          background = theme.colors.base;
          foreground = theme.colors.text;
        };

        urgency_critical = {
          background = theme.colors.base;
          foreground = theme.colors.text;
          frame_color = theme.colors.red;
          highlight = theme.colors.red;
        };

        volume_brightness = {
          summary = "Volume|Brightness";
          history_ignore = true;
          frame_color = theme.colors.text;
          foreground = theme.colors.text;
          background = theme.colors.base;
          highlight = theme.colors.text;
          set_stack_tag = "synchronous";
          timeout = 2;
        };

        volume_icon = {
          summary = "Volume";
          default_icon = toString (cleanSource
          ../../../../assets/images/other/volume.png);
        };

        volume_onehundred = {
          msg_urgency = "low";
          summary = "Volume";
          highlight = theme.colors.sapphire;
          frame_color = theme.colors.sapphire;
        };

        volume_overamplified = {
          msg_urgency = "critical";
          summary = "Volume";
          highlight = theme.colors.maroon;
          frame_color = theme.colors.maroon;
        };

        brightness_icon = {
          summary = "Brightness";
          default_icon = toString (cleanSource
          ../../../../assets/images/other/brightness.png);
        };
      };
    };
  };
}

