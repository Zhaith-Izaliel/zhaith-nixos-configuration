{ config, lib, pkgs, theme, ... }:

with lib;

let
  cfg = config.hellebore.desktop-environment.hyprland.applications-launcher;
in
{
  options.hellebore.desktop-environment.hyprland.applications-launcher = {
    enable = mkEnableOption "Hellebore Anyrun configuration";

    blurBackground = mkOption {
      type = types.path;
      default = ../../../../../assets/images/rofi/blur-wall.png;
      description = "Blurred background used in the applications-launcher theme.";
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
  };

  imports = [
    ./theme.nix
  ];

  config = mkIf cfg.enable {
    programs.rofi = {
      enable = true;

      package = pkgs.rofi-wayland;

      font = "NotoMono Nerd Font 12";

      terminal = strings.optionalString
      config.hellebore.shell.emulator.enable
      config.hellebore.shell.emulator.bin;

      plugins = with pkgs; [
        rofi-top
        rofi-calc
      ];

      extraConfig = {
        modi = "drun,filebrowser,ssh,calc,top";
        show-icons = true;
        display-drun = " Apps";
        display-filebrowser = " Files";
        display-ssh = "󰒍 SSH";
        display-calc = "󰲒 Calc";
        display-top = " Top";
        drun-display-format = "{name}";
        icon-theme = theme.gtk.iconTheme.name;
      };
    };
  };
}

