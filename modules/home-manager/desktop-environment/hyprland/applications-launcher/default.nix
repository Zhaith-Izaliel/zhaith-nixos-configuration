{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.desktop-environment.hyprland.applications-launcher;
in
{
  options.hellebore.desktop-environment.hyprland.applications-launcher = {
    enable = mkEnableOption "Hellebore Anyrun configuration";

    blurBackground = mkOption {
      type = types.path;
      default = ../../../../../assets/images/rofi/blur.wall.png;
      description = "Blurred background used in the applications-launcher theme.";
    };

    background = mkOption {
      type = types.path;
      default = ../../../../../assets/images/rofi/wall.png;
      description = "Background used in the applications-launcher theme.";
    };
  };

  imports = [
    ./theme.nix
  ];

  config = mkIf cfg.enable {
    programs.rofi = {
      enable = true;

      package = pkgs.rofi-wayland;

      terminal = strings.optionalString
      config.hellebore.shell.emulator.enable
      "${config.hellebore.shell.emulator.package}/bin/kitty";

      extraConfig = {
        modi = "drun,filebrowser,window,run";
        show-icons = true;
        display-drun = "";
        display-run = "";
        display-filebrowser = "";
        display-window = "";
        drun-display-format = "{name}";
        window-format = "{w}{t}";
        font = "NotoMono Nerd Font 12";
        icon-theme = "Tela-circle-dracula";
      };
    };
  };
}

