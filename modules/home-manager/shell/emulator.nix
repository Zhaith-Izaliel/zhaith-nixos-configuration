{
  config,
  lib,
  pkgs,
  extra-types,
  ...
}: let
  inherit (lib) concatStringsSep optionalString mkOption mkEnableOption getExe types mkIf;

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
      ${pkgs.procps}/bin/pgrep "alacritty" &> /dev/null
      local exit_code="$?"
      if [ "$exit_code" = "0" ]; then
        ${getExe cfg.package} msg create-window
      else
        ${getExe cfg.package}
      fi
    ''
  ]);
  theme = config.hellebore.theme.themes.${cfg.theme};
in {
  options.hellebore.shell.emulator = {
    enable = mkEnableOption "Hellebore terminal emulator configuration";

    font =
      (extra-types.font {
        size = config.hellebore.font.size;
        sizeDescription = "Set the terminal emulator font size.";
        name = "FiraCode Nerd Font";
        nameDescription = "Set the terminal emulator font family.";
      })
      // {
        enableLigatures = mkEnableOption "Font Ligatures for the Terminal Emulator";
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

    package = mkOption {
      type = types.package;
      default = pkgs.alacritty;
      description = "The default terminal emulator package.";
    };

    bin = mkOption {
      type = types.str;
      default = getExe emulator-bin;
      description = "Get the terminal emulator binary.";
      readOnly = true;
    };
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      package = cfg.package;

      settings = {
        import = [
          (theme.alacritty.file)
        ];

        window = {
          decorations = "None";
          opacity = 0.7;
        };

        font = {
          normal = {
            family = "${cfg.font.name}";
            style = "Regular";
          };

          size = cfg.font.size;
        };

        cursor = {
          style = {
            shape = "Beam";
            blinking = "Always";
          };

          vi_mode_style = {
            shape = "Block";
            blinking = "Always";
          };
        };
      };
    };
  };
}
