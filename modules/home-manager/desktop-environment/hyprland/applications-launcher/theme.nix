{ config, theme, ... }:

let
  inherit (config.lib.formats.rasi) mkLiteral;
  colors = theme.colors;
  cfg = config.hellebore.desktop-environment.hyprland.applications-launcher;
in
{
  programs.rofi.theme = {
    "*" = {
      separatorcolor = mkLiteral "transparent";
      border-color = mkLiteral "transparent";
      border-radius = mkLiteral "0px";
      border = mkLiteral "0px";
      spacing = mkLiteral "0px";
      padding = mkLiteral "0px";
    };

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
      border-color = mkLiteral colors.crust;
    };

    mainbox = {
      enabled = true;
      spacing = mkLiteral "0px";
      orientation = mkLiteral "horizontal";
      children =  [  "inputbar"  "listbox" ];
      background-image = mkLiteral ''url("${cfg.blurBackground}", height)'';
    };

    inputbar = {
      padding-top = mkLiteral "10px";
      enabled = true;
      width = mkLiteral "25%";
      background-color = mkLiteral "transparent";
      children = [ "mode-switcher" "entry" ];
    };

    entry = {
      enabled = false;
    };

    mode-switcher = {
      orientation = mkLiteral "vertical";
      enabled = true;
      background-color = mkLiteral "transparent";
      width = mkLiteral "66px";
      padding = mkLiteral "160px 10px 160px 10px";
      spacing = mkLiteral "25px";
    };

    button = {
      cursor = mkLiteral "pointer";
      font-style = mkLiteral "bold";
      border-radius = mkLiteral "50px";
      background-color = mkLiteral colors.base;
      text-color = mkLiteral colors.surface1;
    };

    "button selected" = {
      background-color = mkLiteral colors.base;
      text-color = mkLiteral colors.text;
    };

    listbox = {
      spacing = mkLiteral "10px";
      padding = mkLiteral "30px";
      children = [ "listview" ];
      # background-color = mkLiteral (colors.crust + "e1");
      background-color = mkLiteral "transparent";
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
      text-color = mkLiteral colors.text;
    };

    element = {
      enabled = true;
      spacing = mkLiteral "30px";
      padding = mkLiteral "8px";
      border-radius = mkLiteral "20px";
      cursor = mkLiteral "pointer";
      background-color = mkLiteral "transparent";
      text-color = mkLiteral colors.text;
    };

    "element normal.normal" = {
      background-color = mkLiteral "transparent";
      text-color = mkLiteral colors.text;
    };

    "element normal.urgent" = {
      background-color = mkLiteral colors.mauve;
      text-color = mkLiteral colors.base;
    };

    "element normal.active" = {
      background-color = mkLiteral colors.green;
      text-color = mkLiteral colors.base;
    };

    "element selected.normal" = {
      background-color = mkLiteral colors.lavender;
      text-color = mkLiteral colors.base;
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

