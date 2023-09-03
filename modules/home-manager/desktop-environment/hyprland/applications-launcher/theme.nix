{ config, theme, lib, ... }:

let
  inherit (config.lib.formats.rasi) mkLiteral;
  colors = theme.colors;
  cfg = config.hellebore.desktop-environment.hyprland.applications-launcher;
  blurBackground = lib.cleanSource cfg.blurBackground;
  background = lib.cleanSource cfg.background;
in
{
  programs.rofi.theme = {
    "*" = {
      foreground = mkLiteral colors.text;
      normal-foreground = mkLiteral "@foreground";
      urgent-foreground = mkLiteral colors.crust;
      active-foreground = mkLiteral colors.crust;

      alternate-normal-foreground = mkLiteral "@normal-foreground";
      alternate-urgent-foreground = mkLiteral "@urgent-foreground";
      alternate-active-foreground = mkLiteral "@active-foreground";

      selected-normal-foreground = mkLiteral colors.crust;
      selected-urgent-foreground = mkLiteral colors.crust;
      selected-active-foreground = mkLiteral colors.crust;

      background = colors.crust;
      normal-background = mkLiteral "@background";
      urgent-background = mkLiteral colors.maroon;
      active-background = mkLiteral colors.teal;

      alternate-normal-background = mkLiteral colors.flamingo;
      alternate-urgent-background = mkLiteral "@urgent-background";
      alternate-active-background = mkLiteral "@active-background";

      selected-normal-background = mkLiteral colors.lavender;
      selected-urgent-background = mkLiteral colors.teal;
      selected-active-background = mkLiteral colors.maroon;

      separatorcolor = mkLiteral "transparent";
      border-color = mkLiteral "transparent";
      border-radius = mkLiteral "0px";
      border = mkLiteral "0px";
      spacing = mkLiteral "0px";
      padding = mkLiteral "0px";
    };

    # FIXME: set literal values where needed
    window = {
      height = mkLiteral "590px";
      width = mkLiteral "1140px";
      transparency = "real";
      fullscreen = false;
      enabled = true;
      cursor = "default";
      spacing = mkLiteral "0px";
      padding = mkLiteral "0px";
      border = mkLiteral "2px";
      border-radius = mkLiteral "40px";
      border-color = mkLiteral "@alternate-normal-background";
      background-color = mkLiteral "transparent";
    };

    mainbox = {
      enabled = true;
      spacing = mkLiteral "0px";
      orientation = mkLiteral "horizontal";
      children =  [  "inputbar"  "listbox" ];
      background-color = mkLiteral "transparent";
      background-image =  mkLiteral ''url("${blurBackground}", height)'';
    };

    inputbar = {
      enabled = true;
      width = mkLiteral "25%";
      children = [ "mode-switcher" "entry" ];
      background-color = mkLiteral "transparent";
      background-image = mkLiteral ''url("${background}", height)'';
    };

    entry = {
      enabled = false;
    };


    mode-switcher = {
      orientation = mkLiteral "vertical";
      enabled = true;
      width = mkLiteral "68px";
      padding = mkLiteral "160px 10px 160px 10px";
      spacing = mkLiteral "25px";
      background-color = mkLiteral "transparent";
      background-image = mkLiteral ''url("${blurBackground}", height)'';
    };

    button = {
      cursor = mkLiteral "pointer";
      border-radius = mkLiteral "50px";
      background-color = mkLiteral "@background";
      text-color = mkLiteral "@foreground";
    };

    "button selected" = {
      background-color = mkLiteral "@foreground";
      text-color = mkLiteral "@background";
    };

    listbox = {
      spacing = mkLiteral "10px";
      padding = mkLiteral "30px";
      children = [ "listview" ];
      background-color = mkLiteral "@background";
    };

    listview = {
      enabled = true;
      columns = 1;
      cycle = true;
      dynamic = true;
      scrollbar = false;
      layout = mkLiteral "vertical";
      reverse = false;
      fixed-height = true;
      fixed-columns = true;
      cursor = "default";
      background-color = mkLiteral "transparent";
      text-color = mkLiteral "@foreground";
    };

    element = {
      enabled = true;
      spacing = mkLiteral "30px";
      padding = mkLiteral "8px";
      border-radius = mkLiteral "20px";
      cursor = mkLiteral "pointer";
      background-color = mkLiteral "transparent";
      text-color = mkLiteral "@foreground";
    };

    "element normal.normal" = {
      background-color = mkLiteral "transparent";
      text-color = mkLiteral "@normal-foreground";
    };

    "element normal.urgent" = {
      background-color = mkLiteral "@urgent-background";
      text-color = mkLiteral "@urgent-foreground";
    };

    "element normal.active" = {
      background-color = mkLiteral "@active-background";
      text-color = mkLiteral "@active-foreground";
    };

    "element selected.normal" = {
      background-color = mkLiteral "@selected-normal-background";
      text-color = mkLiteral "@selected-normal-foreground";
    };

    "element selected.urgent" = {
      background-color = mkLiteral "@selected-urgent-background";
      text-color = mkLiteral "@selected-urgent-foreground";
    };

    "element selected.active" = {
      background-color = mkLiteral "@selected-active-background";
      text-color = mkLiteral "@selected-active-foreground";
    };

    "element-icon" = {
      size = mkLiteral "48px";
      cursor = mkLiteral "inherit";
      background-color = mkLiteral "transparent";
      text-color = mkLiteral "inherit";
    };

    "element-text" = {
      vertical-align = mkLiteral "0.5";
      horizontal-align = mkLiteral "0.0";
      cursor = mkLiteral "inherit";
      background-color = mkLiteral "transparent";
      text-color = mkLiteral "inherit";
    };
  };
}

