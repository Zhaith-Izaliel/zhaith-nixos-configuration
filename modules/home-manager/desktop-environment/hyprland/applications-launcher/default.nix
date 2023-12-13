{ config, lib, pkgs, theme, ... }:

with lib;

let
  cfg = config.hellebore.desktop-environment.hyprland.applications-launcher;
in
{
  options.hellebore.desktop-environment.hyprland.applications-launcher = {
    enable = mkEnableOption "Hellebore Applications Launcher configuration";

    fontSize = mkOption {
      type = types.int;
      default = config.hellebore.fontSize;
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

  imports = [
    ./theme.nix
  ];

  config = mkIf cfg.enable {
    programs.rofi = {
      enable = true;

      package = pkgs.rofi-wayland;

      font = "NotoMono Nerd Font ${toString cfg.fontSize}";

      terminal = strings.optionalString
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

