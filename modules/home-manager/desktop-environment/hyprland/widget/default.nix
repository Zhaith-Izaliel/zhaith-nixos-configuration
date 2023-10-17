{ config, lib, ... }:

with lib;

let
  cfg = config.hellebore.desktop-environment.hyprland.widget;
in
{
  options.hellebore.desktop-environment.hyprland.widget = {
    enable = mkEnableOption "Hellebore's desktop environment widgets";
  };

  config = mkIf cfg.enable {
    programs.eww = {
      enable = true;
      configDir = ./config;
    };
  };
}

