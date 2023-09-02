{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.desktop-environment.hyprland.applications-launcher;
in
{
  options.hellebore.desktop-environment.hyprland.applications-launcher = {
    enable = mkEnableOption "Hellebore Anyrun configuration";
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

      };
    };
  }

