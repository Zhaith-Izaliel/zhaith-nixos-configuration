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
    (getExe cfg.package)
  ]);
  theme = config.hellebore.theme.themes.${cfg.theme};
in {
  options.hellebore.shell.emulator = {
    enable = mkEnableOption "Hellebore terminal emulator configuration";

    font =
      (extra-types.font {
        size = config.hellebore.font.size;
        sizeDescription = "Set the terminal emulator font size.";
        name = "Fira Code";
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
      default = pkgs.wezterm;
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
    programs.wezterm = {
      inherit (cfg) enable package;

      enableBashIntegration = config.programs.bash.enable;
      enableZshIntegration = config.programs.zsh.enable;

      extraConfig = ''
        local wezterm = require("wezterm");

        return {
          font = wezterm.font {
            family = "${cfg.font.name}",
            harfbuzz_features = { 'liga=${
          if cfg.font.enableLigatures
          then toString 1
          else toString 0
        }' },
          },
          font_size = ${toString cfg.font.size},
          hide_tab_bar_if_only_one_tab = true,
          color_scheme = "${theme.wezterm.theme}",
          window_background_opacity = 0.9,
          skip_close_confirmation_for_processes_named = {
            'bash',
            'zellij',
            'sh',
            'zsh',
            'fish',
            'tmux',
            'nu',
            'cmd.exe',
            'pwsh.exe',
            'powershell.exe',
          },
        }
      '';
    };
  };
}
