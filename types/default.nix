{
  lib,
  inputs,
  pkgs,
}: let
  inherit (lib) types mkOption;
  themes = import ../themes {inherit lib pkgs inputs;};
in rec {
  monitor = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "The monitor name, usually reported with `xrandr`, `wl-randr`,
        `hyprctl monitors`, etc.";
      };
      width = mkOption {
        type = types.int;
        description = "The width (in pixel) of the monitor.";
      };
      height = mkOption {
        type = types.int;
        description = "The height (in pixel) of the monitor.";
      };
      refreshRate = mkOption {
        type = types.int;
        description = "The refresh rate (in Hz) of the monitor.";
      };
      xOffset = mkOption {
        type = types.int;
        description = "The offset (in pixel) of the monitor, on the X axis.";
        default = 0;
      };
      yOffset = mkOption {
        type = types.int;
        description = "The offset (in pixel) of the monitor, on the Y axis.";
        default = 0;
      };
      scaling = mkOption {
        type = types.float;
        description = "The scaling of the display, as a floating point value.";
        default = 1.0;
      };
      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Extra arguments used to describe the monitor. These
        arguments are used with Hyprland.";
        default = [];
      };
    };
  };

  fontSize = {
    default,
    description,
  }:
    mkOption {
      inherit default description;
      type = types.ints.unsigned;
    };

  font = {
    name,
    nameDescription,
    size,
    sizeDescription,
  }: {
    size = fontSize {
      default = size;
      description = sizeDescription;
    };

    name = mkOption {
      type = types.nonEmptyStr;
      default = name;
      description = nameDescription;
    };
  };

  keyboard = {
    layout,
    variant,
  }: {
    layout = mkOption {
      type = types.nonEmptyStr;
      default = layout;
      description = "Defines the keyboard layout.";
    };
    variant = mkOption {
      type = types.nonEmptyStr;
      default = variant;
      description = "Defines the keyboard variant.";
    };
  };

  monitors = mkOption {
    default = [];
    type = types.listOf monitor;
    description = "A list describing the monitors configuration.";
  };

  theme = {
    name = {
      default ? "",
      description,
    }:
      mkOption {
        inherit default description;
        type = types.nonEmptyStr;
      };

    themes = mkOption {
      default = themes;
      # TEMP: should be submodule, it's for testing purposes only
      type = types.attrsOf types.anything;
      description = "The attribut set containing the theme elements. Read only.";
      readOnly = true;
    };
  };
}
