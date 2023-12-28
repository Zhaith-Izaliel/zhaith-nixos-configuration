{ config, lib, pkgs, extra-types, ... }:

let
  inherit (config.lib.formats.rasi) mkLiteral;
  inherit (lib) mkEnableOption mkIf mkOption types optionalString;
  cfg = config.hellebore.desktop-environment.applications-launcher;
  theme = config.hellebore.theme.themes.${cfg.theme};
in
{
  options.hellebore.desktop-environment.applications-launcher = {
    enable = mkEnableOption "Hellebore Applications Launcher configuration";

    fontSize = extra-types.fontSize {
      default = config.hellebore.font.size;
      description = "Set the font size to manage the UI size.";
    };

    background = mkOption {
      type = types.path;
      default = ../../../../../assets/images/rofi/wall.png;
      description = "Background used in the applications-launcher theme.";
    };

    command = mkOption {
      type = types.str;
      default = "${config.programs.rofi.finalPackage}/bin/rofi -show drun";
      readOnly = true;
      description = "The command to show the applications launcher.";
    };

    theme = extra-types.theme.name {
      default = config.hellebore.theme.name;
      description = "The application launcher theme to use. Default to global
      theme.";
    };

    width = mkOption {
      type = types.str;
      default = "1600px";
      description = "Width of the default Rofi window.";
    };

    height = mkOption {
      type = types.str;
      default = "700px";
      description = "Height of the default Rofi window.";
    };
  };

  config = mkIf cfg.enable {
    programs.rofi = {
      enable = true;

      package = pkgs.rofi-wayland;

      font = "NotoMono Nerd Font ${toString cfg.fontSize}";

      terminal = optionalString
      config.hellebore.shell.emulator.enable
      config.hellebore.shell.emulator.bin;

      plugins = with pkgs; [
        rofi-calc
      ];

      extraConfig = {
        modi = "drun,calc";
        show-icons = true;
        display-drun = " Apps";
        display-calc = "󰲒 Calc";
        drun-display-format = "{name}";
        icon-theme = theme.gtk.iconTheme.name;
        window-format = "{w} · {c} · {t}";
      };

      theme = {
        window = {
          width = mkLiteral cfg.width;
          height = mkLiteral cfg.height;
          cursor = theme.gtk.cursorTheme.name;
        };
      } // theme.rofi.theme {
        inherit mkLiteral; inherit (cfg) background;
      };

      applets = {
        bluetooth = {
          enable = true;
          settings = {
          };
        };

        quicklinks = {
          enable = true;
          settings = {
            quicklinks = {
              " Reddit" = "https://www.reddit.com/";
              " Gitlab" = "https://gitlab.com/";
            };
          };
        };

        favorites = {
          enable = true;
        };
      };
    };
  };
}

