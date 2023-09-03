{ config, theme, lib, ... }:

let
  colors = theme.colors;
  cfg = config.hellebore.desktop-environment.hyprland.applications-launcher;
  blurBackground = lib.cleanSource cfg.blurBackground;
  background = lib.cleanSource cfg.background;
in
{
  programs.rofi.theme = {
    "*" = {
      foreground = colors.text;
      normal-foreground = "@foreground";
      urgent-foreground = colors.crust;
      active-foreground = colors.crust;

      alternate-normal-foreground = "@normal-foreground";
      alternate-urgent-foreground = "@urgent-foreground";
      alternate-active-foreground = "@active-foreground";

      selected-normal-foreground = colors.crust;
      selected-urgent-foreground = colors.crust;
      selected-active-foreground = colors.crust;

      background = colors.crust;
      normal-background = "@background";
      urgent-background = colors.maroon;
      active-background = colors.teal;

      alternate-normal-background = colors.flamingo;
      alternate-urgent-background = "@urgent-background";
      alternate-active-background = "@active-background";

      selected-normal-background =  colors.lavender;
      selected-urgent-background =  colors.teal;
      selected-active-background =  colors.maroon;

      separatorcolor = "transparent";
      border-color = "transparent";
      border-radius = "0px";
      border = "0px";
      spacing = "0px";
      padding = "0px";
    };

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

