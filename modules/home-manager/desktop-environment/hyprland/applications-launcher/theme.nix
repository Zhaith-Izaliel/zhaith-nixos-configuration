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
      height = "590px";
      width = "1140px";
      transparency = "real";
      fullscreen = false;
      enabled = true;
      cursor = "default";
      spacing = "0px";
      padding = "0px";
      border = "2px";
      border-radius = "40px";
      border-color = "@alternate-normal-background";
      background-color = "transparent";
    };

    mainbox = {
      enabled = true;
      spacing = "0px";
      orientation = "horizontal";
      children =  [  "inputbar"  "listbox" ];
      background-color = "transparent";
      background-image =  ''url("${blurBackground}", height)'';
    };

    inputbar = {
      enabled = true;
      width = "25%";
      children = [ "mode-switcher" "entry" ];
      background-color = "transparent";
      background-image = ''url("${background}", height)'';
    };

    entry = {
      enabled = false;
    };


    mode-switcher = {
      orientation = "vertical";
      enabled = true;
      width = "68px";
      padding = "160px 10px 160px 10px";
      spacing = "25px";
      background-color = "transparent";
      background-image = ''url("${blurBackground}", height)'';
    };

    button = {
      cursor = "pointer";
      border-radius = "50px";
      background-color = "@background";
      text-color = "@foreground";
    };

    "button selected" = {
      background-color = "@foreground";
      text-color = "@background";
    };

    listbox = {
      spacing = "10px";
      padding = "30px";
      children = [ "listview" ];
      background-color = "@background";
    };

    listview = {
      enabled = true;
      columns = 1;
      cycle = true;
      dynamic = true;
      scrollbar = false;
      layout = "vertical";
      reverse = false;
      fixed-height = true;
      fixed-columns = true;
      cursor = "default";
      background-color = "transparent";
      text-color = "@foreground";
    };

    element = {
      enabled = true;
      spacing = "30px";
      padding = "8px";
      border-radius = "20px";
      cursor = "pointer";
      background-color = "transparent";
      text-color = "@foreground";
    };

    "element normal.normal" = {
      background-color = "transparent";
      text-color = "@normal-foreground";
    };

    "element normal.urgent" = {
      background-color = "@urgent-background";
      text-color = "@urgent-foreground";
    };

    "element normal.active" = {
      background-color = "@active-background";
      text-color = "@active-foreground";
    };

    "element selected.normal" = {
      background-color = "@selected-normal-background";
      text-color = "@selected-normal-foreground";
    };

    "element selected.urgent" = {
      background-color = "@selected-urgent-background";
      text-color = "@selected-urgent-foreground";
    };

    "element selected.active" = {
      background-color = "@selected-active-background";
      text-color = "@selected-active-foreground";
    };

    "element-icon" = {
      size = "48px";
      cursor = "inherit";
      background-color = "transparent";
      text-color = "inherit";
    };

    "element-text" = {
      vertical-align = 0.5;
      horizontal-align = 0.0;
      cursor = "inherit";
      background-color = "transparent";
      text-color = "inherit";
    };
  };
}

