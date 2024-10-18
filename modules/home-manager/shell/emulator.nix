{
  config,
  lib,
  pkgs,
  extra-types,
  inputs,
  ...
}: let
  inherit (lib) mkOption mkEnableOption getExe types mkIf mkPackageOption concatStringsSep optionalString;

  cfg = config.hellebore.shell.emulator;
  emulator-bin = pkgs.writeScriptBin "emulator-bin" ''
    # WAYLAND_DISPLAY=1
    ${getExe cfg.package}
  '';
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

    theme = extra-types.theme.name {
      default = config.hellebore.theme.name;
      description = "Defines the terminal emulator theme.";
    };

    package = mkPackageOption pkgs "wezterm" {};

    bin = mkOption {
      type = types.str;
      default = getExe emulator-bin;
      description = "Get the terminal emulator binary.";
      readOnly = true;
    };

    multiplexing = mkOption {
      type = types.enum ["plain" "full"];
      default = "plain";
      description = ''
        Set terminal multiplexing mode for the emulator.

        - `plain`: no terminal multiplexing, you should use something like Zellij if you need it
        - `full`: full terminal multiplexing support.

      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    programs.wezterm = {
      inherit (cfg) package;
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;

      extraConfig = concatStringsSep "\n" [
        ''
          local wezterm = require("wezterm")
          local config = wezterm.config_builder() or {}
        ''
        ''
          config.enable_wayland = ${
            if config.wayland.windowManager.hyprland.enable
            then "true"
            else "false"
          }
        ''
        (
          optionalString (cfg.multiplexing == "plain")
          ''
            config.enable_tab_bar = false
            config.use_fancy_tab_bar = false
            config.show_tabs_in_tab_bar = false
            config.show_new_tab_button_in_tab_bar = false
            config.disable_default_key_bindings = true

            config.keys = {
              { mods = "CTRL|SHIFT", key = "c", action = wezterm.action.CopyTo "Clipboard" },
              { mods = "CTRL|SHIFT", key = "v", action = wezterm.action.PasteFrom "Clipboard" },
              { mods = "CTRL", key = "Insert", action = wezterm.action.CopyTo "PrimarySelection" },
              { mods = "SHIFT", key = "Insert", action = wezterm.action.PasteFrom "PrimarySelection" },
              { mods = "CTRL|SHIFT", key = "g", action = wezterm.action.ActivateCommandPalette },
              { mods = "CTRL|SHIFT", key = "l", action = wezterm.action.ShowDebugOverlay },
            }
          ''
        )
        ''
          -- colorscheme
          config.color_scheme = "${theme.theme}"
          config.window_background_opacity = 0.85

          config.font_size = ${toString cfg.font.size}
          config.font = wezterm.font_with_fallback({
          	{
          		family = "${cfg.font.name}",
          		weight = "Regular",
          		harfbuzz_features = { "calt=1", "clig=1", "liga=1" },
          	},
          	{ family = "${cfg.font.emoji}", weight = "Regular" },
          	{ family = "${cfg.font.nerd-font}", weight = "Regular" },
          })

          config.window_close_confirmation = "NeverPrompt"

          config.enable_kitty_keyboard = true

          config.audible_bell = "Disabled";

          config.window_padding = {
           left = 0,
           right = 0,
           top = 0,
           bottom = 0,
          }

          return config
        ''
      ];
    };
  };
}
