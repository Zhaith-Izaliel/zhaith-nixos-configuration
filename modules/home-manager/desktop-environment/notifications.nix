{
  config,
  lib,
  extra-types,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkPackageOption mkIf types elemAt splitString;
  cfg = config.hellebore.desktop-environment.notifications;
  theme = config.hellebore.theme.themes.${cfg.theme};
  finalPositions = let
    positions = splitString "-" cfg.position;
  in {
    x = elemAt positions 1;
    y = elemAt positions 0;
  };
in {
  options.hellebore.desktop-environment.notifications = {
    enable = mkEnableOption "Hellebore's notifications center configuration";

    package = mkPackageOption pkgs "swaynotificationcenter" {};

    font = extra-types.font {
      inherit (config.hellebore.font) name size;
      sizeDescription = "Set the notifications client font size.";
      nameDescription = "Set the notifications client font family.";
    };

    theme = extra-types.theme.name {
      default = config.hellebore.theme.name;
      description = "Defines the notifications client theme.";
    };

    width = mkOption {
      type = types.ints.unsigned;
      default = 400;
      description = "Defines the width of the notifications client.";
    };

    timeouts = {
      normal = mkOption {
        type = types.ints.unsigned;
        default = 10;
        description = "Defines the low priority notifications timeout.";
      };

      low = mkOption {
        type = types.ints.unsigned;
        default = 5;
        description = "Defines the low priority notifications timeout.";
      };

      critical = mkOption {
        type = types.ints.unsigned;
        default = 0;
        description = "Defines the low priority notifications timeout.";
      };
    };

    position = mkOption {
      type = types.enum [
        "top-right"
        "top-left"
        "top-center"
        "bottom-right"
        "bottom-left"
        "bottom-center"
        "center-right"
        "center-left"
        "center"
      ];
      default = "top-right";
      description = "Set the position of the notifications client.";
    };

    notifications-visibility = mkOption {
      default = {};
      description = ''
        Set the visibility or override urgency of each incoming notification.

        If the notification doesn't include one of the properties, that property will be ignored.
        All properties (except for state) use regex.
        If all properties match the given notification, the notification will be follow the provided state.
        Only the first matching object will be used.
      '';

      example = ''
        {
          example-name = {
            state = "The notification state";
            app-name = Notification app-name Regex";
            summary= "Notification summary Regex";
            body= "Notification body Regex";
            urgency= "Low or Normal or Critical";
            category= "Notification category Regex";
          };
        }
      '';
    };

    control-center = {
      height = mkOption {
        type = types.ints.unsigned;
        default = 400;
        description = ''
          Defines the height of the notifications control center.

          This setting is ignored when `fit-to-screen` is set to `true`.
        '';
      };

      width = mkOption {
        type = types.ints.unsigned;
        default = 400;
        description = "Defines the width of the notifications control client.";
      };

      fit-to-screen =
        mkEnableOption null
        // {
          description = "Whether the control center should expand vertically to fill the screen.";
        };

      hide-on-clear =
        mkEnableOption null
        // {
          description = "Hides the control center after pressing \"Clear All\"";
        };

      hide-on-action =
        mkEnableOption null
        // {
          description = "Hides the control center when clicking on notification action.";
          default = true;
        };
      keyboard-shortcuts =
        mkEnableOption null
        // {
          description = "Whether the control center should use keyboard shortcuts.";
          default = true;
        };

      relative-timestamps =
        mkEnableOption null
        // {
          description = ''
            Display notification timestamps relative to now e.g. "26 minutes ago".

            If false, a local iso8601-formatted absolute timestamp is displayed.
          '';
        };
    };
  };

  config = mkIf cfg.enable {
    # services.dunst = {
    #   enable = true;
    #   inherit (theme.gtk) iconTheme;

    #   settings = recursiveUpdate theme.dunst.settings {
    #     global = {
    #       inherit (cfg) width height;
    #       font = "${cfg.font.name} ${toString cfg.font.size}";
    #       origin = cfg.position;
    #       progress_bar = true;
    #       enable_posix_regex = true;
    #     };

    #     volume_brightness = {
    #       summary = "Volume|Brightness";
    #       history_ignore = true;
    #       set_stack_tag = "synchronous";
    #       timeout = 2;
    #     };

    #     volume_icon = {
    #       summary = "Volume";
    #       default_icon = toString (cleanSource ../../../assets/images/icons/volume.png);
    #     };

    #     volume_onehundred = {
    #       msg_urgency = "low";
    #       summary = "Volume";
    #     };

    #     volume_overamplified = {
    #       msg_urgency = "critical";
    #       summary = "Volume";
    #     };

    #     brightness_icon = {
    #       summary = "Brightness";
    #       default_icon = toString (cleanSource ../../../assets/images/icons/brightness.png);
    #     };
    #   };
    # };

    services.swaync = {
      inherit (cfg) package;
      enable = true;
      # style = theme.swaync.style;
      settings = {
        inherit (cfg.control-center) fit-to-screen relative-timestamps hide-on-clear hide-on-action keyboard-shortcuts;

        positionX = finalPositions.x;
        positionY = finalPositions.y;
        layer = "overlay";
        layer-shell = true;
        cssPriority = "user";
        notification-window-width = cfg.width;
        timeout = cfg.timeouts.normal;
        timeout-low = cfg.timeouts.low;
        timeout-critical = cfg.timeouts.critical;
        control-center-height = cfg.control-center.height;
        control-center-width = cfg.control-center.width;
      };
    };
  };
}
