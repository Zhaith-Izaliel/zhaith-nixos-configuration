{ config, theme, ... }:

let
  inherit (config.lib.formats.rasi) mkLiteral;
  colors = theme.colors;
  cfg = config.hellebore.desktop-environment.hyprland.applications-launcher;
in
{
  programs.rofi.theme = {
    window = {
      # properties for window widget
      transparency = "real";
      location = mkLiteral "center";
      anchor = mkLiteral "center";
      fullscreen = false;
      width = mkLiteral cfg.width;
      height = mkLiteral cfg.height;
      x-offset = mkLiteral "0px";
      y-offset = mkLiteral "0px";

      # properties for all widgets
      enabled = true;
      border-radius = mkLiteral "15px";
      cursor = theme.gtk.cursorTheme.name;
      background-color = mkLiteral colors.base;
      border = mkLiteral "3px";
      border-color = mkLiteral colors.mauve;
    };

    mainbox = {
      enabled = true;
      spacing = mkLiteral "0px";
      orientation = mkLiteral "horizontal";
      children =  [  "imagebox"  "listbox" ];
      background-color = mkLiteral "transparent";
    };

    imagebox = {
      enabled = true;
      padding = mkLiteral "1.25em";
      background-color = mkLiteral "transparent";
      background-image = mkLiteral ''url("${cfg.background}", height)'';
      orientation = mkLiteral "vertical";
      children = [ "inputbar" "dummy" "mode-switcher" ];
    };

    listbox = {
      enabled = true;
      spacing = mkLiteral "1.25em";
      padding = mkLiteral "1.25em";
      children = [ "message" "listview" ];
      orientation = mkLiteral "vertical";
      background-color = mkLiteral "transparent";
    };

    dummy = {
      enabled = true;
      background-color = mkLiteral "transparent";
    };

    inputbar = {
      enabled = true;
      padding = mkLiteral "15px";
      spacing = mkLiteral "10px";
      border-radius = mkLiteral "10px";
      background-color = mkLiteral colors.mantle;
      border-color = mkLiteral colors.blue;
      border = mkLiteral "2px";
      text-color = mkLiteral colors.text;
      children = [ "textbox-prompt-colon" "entry" ];
    };

    textbox-prompt-colon = {
      enabled = true;
      expand = false;
      str = "";
      background-color = mkLiteral "inherit";
      text-color = mkLiteral "inherit";
    };

    entry = {
      enabled = true;
      background-color = mkLiteral "inherit";
      text-color = mkLiteral "inherit";
      cursor = mkLiteral "text";
      placeholder = "Search";
      placeholder-color = mkLiteral "inherit";
    };

    mode-switcher = {
      enabled = true;
      background-color = mkLiteral "transparent";
      text-color = mkLiteral colors.text;
      spacing = mkLiteral "1.25em";
    };

    button = {
      padding = mkLiteral "0.95em";
      cursor = mkLiteral "pointer";
      font-style = mkLiteral "bold";
      border-radius = mkLiteral "10px";
      border = mkLiteral "2px";
      border-color = mkLiteral colors.blue;
      background-color = mkLiteral colors.mantle;
      text-color = mkLiteral "inherit";
    };

    "button selected" = {
      background-color = mkLiteral colors.lavender;
      text-color = mkLiteral colors.base;
    };

    listview = {
      enabled = true;
      columns = 1;
      lines = 8;
      cycle = true;
      dynamic = true;
      scrollbar = false;
      layout = mkLiteral "vertical";
      reverse = false;
      fixed-height = true;
      fixed-columns = true;
      spacing = mkLiteral "0.625em";
      cursor = "default";
      background-color = mkLiteral "transparent";
      text-color = mkLiteral colors.text;
    };

    element = {
      enabled = true;
      spacing = mkLiteral "0.95em";
      padding = mkLiteral "0.5em";
      border-radius = mkLiteral "10px";
      cursor = mkLiteral "pointer";
      background-color = mkLiteral "transparent";
      text-color = mkLiteral colors.text;
    };

    "element normal.normal" = {
      background-color = mkLiteral "inherit";
      text-color = mkLiteral "inherit";
    };

    "element normal.urgent" = {
      text-color = mkLiteral colors.green;
      background-color = mkLiteral "transparent";
    };

    "element normal.active" = {
      text-color = mkLiteral colors.mauve;
      background-color = mkLiteral "transparent";
    };

    "element alternate.normal" = {
      background-color = mkLiteral "inherit";
      text-color = mkLiteral "inherit";
    };

    "element alternate.urgent" = {
      text-color = mkLiteral colors.green;
      background-color = mkLiteral "transparent";
    };

    "element alternate.active" = {
      text-color = mkLiteral colors.mauve;
      background-color = mkLiteral "transparent";
    };


    "element selected.normal" = {
      background-color = mkLiteral colors.lavender;
      text-color = mkLiteral colors.base;
    };

    "element selected.urgent" = {
      background-color = mkLiteral colors.green;
      text-color = mkLiteral colors.base;
    };

    "element selected.active" = {
      background-color = mkLiteral colors.mauve;
      text-color = mkLiteral colors.base;
    };

    "element-icon" = {
      size = mkLiteral "32px";
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

    message = {
      background-color = mkLiteral "transparent";
    };

    textbox = {
      padding = mkLiteral "0.95em";
      border-radius = mkLiteral "10px";
      background-color = mkLiteral colors.mantle;
      text-color = mkLiteral colors.text;
      vertical-align = mkLiteral "0.5";
      horizontal-align = mkLiteral "0.0";
    };

    error-message = {
      padding = mkLiteral "15px";
      border-radius = mkLiteral "20px";
      background-color = mkLiteral colors.base;
      text-color = mkLiteral colors.text;
    };
  };
}

