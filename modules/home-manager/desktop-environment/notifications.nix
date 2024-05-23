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
      description = "Set the width of the notifications client.";
    };

    height = mkOption {
      type = types.ints.unsigned;
      default = 400;
      description = "Set the height of the notifications client.";
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
        positionX = finalPositions.x;
        positionY = finalPositions.y;
      };
    };
  };
}
