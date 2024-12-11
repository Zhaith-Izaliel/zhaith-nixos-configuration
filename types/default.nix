{
  lib,
  inputs,
  pkgs,
  extra-utils,
}: let
  inherit (lib) types mkOption mkPackageOption mkEnableOption;
  themes = import ../themes {inherit lib pkgs inputs extra-utils;};
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
        type = types.float;
        description = "The refresh rate (in Hz) of the monitor.";
      };
      resolution = mkOption {
        type = types.str;
        default = "";
        description = "The resolution string, according to Hyprland monitors. See https://wiki.hyprland.org/Configuring/Monitors/";
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
      description = "The attributes set containing the theme elements. Read only.";
      readOnly = true;
    };
  };

  server-app = {
    name,
    package ? null,
    user ? "",
    group ? "",
    port ? null,
    database ? "",
    domain ? "",
  }: {
    enable = mkEnableOption "Hellebore's ${name} configuration";

    name = mkOption {
      type = types.nonEmptyStr;
      default = name;
      readOnly = true;
      description = "Name of the Server App. Read Only.";
    };

    package = mkPackageOption pkgs package {nullable = package == null;};

    group = mkOption {
      type = types.nonEmptyStr;
      default = group;
      description = "Defines the user group for ${name}.";
    };

    user = mkOption {
      type = types.nonEmptyStr;
      default = user;
      description = "Defines the user for ${name}";
    };

    database = mkOption {
      type = types.nonEmptyStr;
      default = database;
      description = "The database name for ${name}.";
    };

    port = mkOption {
      type = types.nullOr types.ints.unsigned;
      default = port;
      description = "Defines the port on which ${name} runs on.";
    };

    subdomain = mkOption {
      type = types.nonEmptyStr;
      default = "";
      description = "Defines the subdomain on which ${name} is served.";
    };

    domain = mkOption {
      type = types.nonEmptyStr;
      default = domain;
      description = "Defines the domain on which ${name} is served. This overrides the subdomain.";
    };
  };
}
