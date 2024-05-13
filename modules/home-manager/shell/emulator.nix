{
  config,
  lib,
  pkgs,
  extra-types,
  ...
}: let
  inherit (lib) concatStringsSep optionalString mkOption mkEnableOption getExe types mkIf mkPackageOption;

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
  theme = config.hellebore.theme.themes.${cfg.theme}.wezterm;
in {
  options.hellebore.shell.emulator = {
    enable = mkEnableOption "Hellebore terminal emulator configuration";

    font =
      extra-types.font {
        size = config.hellebore.font.size;
        sizeDescription = "Set the terminal emulator font size.";
        name = "Fira Code";
        nameDescription = "Set the terminal emulator font family.";
      }
      // {
        emoji = mkOption {
          default = "Noto Color Emoji";
          type = types.nonEmptyStr;
          description = "Defines the font used to render emojis.";
        };

        nerd-font = mkOption {
          default = "FiraCode Nerd Font";
          type = types.nonEmptyStr;
          description = "Defines the font use to render Nerdfonts glyphs.";
        };
      };

    enableZshIntegration = mkEnableOption "ZSH integration";

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

    package = mkPackageOption pkgs "wezterm" {};

    bin = mkOption {
      type = types.str;
      default = getExe emulator-bin;
      description = "Get the terminal emulator binary.";
      readOnly = true;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    programs.wezterm = {
      inherit (cfg) package;
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;

      extraConfig = ''
        local wezterm = require("wezterm")
        local config = wezterm.config_builder() or {}

        config.enable_wayland = false

        -- don't care about tabs
        config.enable_tab_bar = false
        config.use_fancy_tab_bar = false
        config.show_tabs_in_tab_bar = false
        config.show_new_tab_button_in_tab_bar = false

        -- colorscheme
        config.color_scheme = "${theme.theme}"
        config.window_background_opacity = 0.85

        config.font = wezterm.font_with_fallback({
        	{
        		family = "${cfg.font.name}",
        		weight = "Regular",
        		harfbuzz_features = { "calt=1", "clig=1", "liga=1" },
        	},
        	{ family = "${cfg.font.emoji}", weight = "Regular" },
        	{ family = "${cfg.font.nerd-font}", weight = "Regular" },
        })

        config.window_padding = {
         left = 0,
         right = 0,
         top = 0,
         bottom = 0,
        }

        return config
      '';
    };
  };
}
