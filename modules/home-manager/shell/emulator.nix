{
  config,
  lib,
  pkgs,
  extra-types,
  ...
}: let
  inherit (lib) concatStringsSep optionalString mkOption mkEnableOption getExe types mkIf mkPackageOption;
  toYAML = lib.generators.toYAML {};

  cfg = config.hellebore.shell.emulator;
  emulator-bin = pkgs.writeScriptBin "emulator-bin" (concatStringsSep "\n" [
    (
      optionalString cfg.integratedGPU.enable
      ''
        export MESA_LOADER_DRIVER_OVERRIDE=${cfg.integratedGPU.driver}
        export __EGL_VENDOR_LIBRARY_FILENAMES=${pkgs.mesa.drivers}/share/glvnd/egl_vendor.d/50_mesa.json
      ''
    )
    ''
      ${getExe cfg.package}
    ''
  ]);
  theme = config.hellebore.theme.themes.${cfg.theme};
in {
  options.hellebore.shell.emulator = {
    enable = mkEnableOption "Hellebore terminal emulator configuration";

    font = extra-types.font {
      size = config.hellebore.font.size;
      sizeDescription = "Set the terminal emulator font size.";
      name = "FiraCode Nerd Font";
      nameDescription = "Set the terminal emulator font family.";
    };

    theme = extra-types.theme.name {
      default = config.hellebore.theme.name;
      description = "Defines the terminal emulator theme.";
    };

    integratedGPU = {
      enable =
        mkEnableOption null
        // {
          description = "Enable the terminal emulator to run on the integrated GPU on a multi GPU
        setup.";
        };
      driver = mkOption {
        type = types.enum ["i965" "iris" "radeonsi"];
        default = "";
        description = "Defines the driver to run the terminal emulator on a multi GPU setup.";
      };
    };

    package = mkPackageOption pkgs "contour" {};

    bin = mkOption {
      type = types.str;
      default = getExe emulator-bin;
      description = "Get the terminal emulator binary.";
      readOnly = true;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];
    xdg.configFile."contour/contour.yml".text = toYAML {
      color_schemes = theme.contour.theme;
      profiles.main = {
        colors = theme.contour.name;
        live_config = true;

        bell.sound = "off";

        terminal_size = {
          columns = 100;
          lines = 45;
        };

        font = {
          inherit (cfg.font) size;
          regular = {
            family = cfg.font.name;
            dpi_scale = 255.0;
            builtin_box_drawing = false;
            strict_spacing = false;
          };
        };

        draw_bold_text_with_bright_colors = false;

        permissions = {
          change_font = "allow";
          capture_buffer = "allow";
        };

        background = {
          opacity = 0.8;
          blur = true;
        };
      };
    };
  };
}
