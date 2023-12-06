{ lib }:
let
  inherit (lib) types mkOption;
in
rec {
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
        type = types.str;
        description = "Extra arguments used to describe the monitor. These
        arguments are used with Hyprland.";
        default = "";
      };
    };
  };

  fontSize = mkOption {
    type = types.ints.unsigned;
    default = 12;
    description = "Define a global font size for applications. Each
    application font size can be changed granularly, or set globally using
    this option.";
  };

  monitors = mkOption {
    type = types.listOf monitor;
    default = [];
    description = "A list describing the monitors configuration.";
  };
}

