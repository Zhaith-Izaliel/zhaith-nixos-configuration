{mkLiteral}: {
  vertical-theme = {
    background,
    background-alt,
    text,
    selected,
    highlight,
    highlight-alt,
    active,
    urgent,
    icon,
    image,
    font,
  }: {
    "*" = {
      font = "${font.name} ${toString font.size}";
    };

    configuration = {
      show-icons = false;
    };

    window = {
      enabled = true;
      transparency = "real";
      location = mkLiteral "center";
      anchor = mkLiteral "center";
      fullscreen = false;
      x-offset = mkLiteral "0px";
      y-offset = mkLiteral "0px";
      border-radius = mkLiteral "15px";
      background-color = mkLiteral background;
      border = mkLiteral "3px";
      border-color = mkLiteral highlight-alt;
    };

    mainbox = {
      enabled = true;
      spacing = mkLiteral "0px";
      orientation = mkLiteral "horizontal";
      children = ["imagebox" "listbox" "message"];
      background-color = mkLiteral "transparent";
    };

    imagebox = {
      enabled = true;
      padding = mkLiteral "1.25em";
      background-color = mkLiteral "transparent";
      background-image = mkLiteral ''url("${image}", height)'';
      orientation = mkLiteral "vertical";
      children = ["inputbar" "dummy"];
    };

    listbox = {
      enabled = true;
      padding = mkLiteral "1.25em";
      spacing = mkLiteral "1.25em";
      children = ["listview"];
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
      background-color = mkLiteral background-alt;
      border-color = mkLiteral highlight;
      border = mkLiteral "2px";
      text-color = mkLiteral text;
      children = [
        "dummy"
        "textbox-prompt-colon"
        "prompt"
        "dummy"
      ];
    };

    textbox-prompt-colon = {
      enabled = true;
      expand = false;
      str = icon;
      text-transform = "bold";
      background-color = mkLiteral "inherit";
      text-color = mkLiteral "inherit";
    };

    prompt = {
      enabled = true;
      background-color = mkLiteral "inherit";
      text-color = mkLiteral "inherit";
    };

    mode-switcher = {
      enabled = false;
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
      text-color = mkLiteral text;
    };

    element = {
      enabled = true;
      spacing = mkLiteral "0.95em";
      padding = mkLiteral "0.5em";
      border-radius = mkLiteral "10px";
      cursor = mkLiteral "pointer";
      background-color = mkLiteral "transparent";
      text-color = mkLiteral text;
    };

    "element normal.normal, element alternate.normal" = {
      background-color = mkLiteral "inherit";
      text-color = mkLiteral "inherit";
    };

    "element normal.urgent, element alternate.urgent" = {
      text-color = mkLiteral urgent;
      background-color = mkLiteral "transparent";
    };

    "element normal.active, element alternate.active" = {
      text-color = mkLiteral active;
      background-color = mkLiteral "transparent";
    };

    "element selected.normal" = {
      background-color = mkLiteral selected;
      text-color = mkLiteral background;
    };

    "element selected.urgent" = {
      background-color = mkLiteral urgent;
      text-color = mkLiteral background;
    };

    "element selected.active" = {
      background-color = mkLiteral active;
      text-color = mkLiteral background;
    };

    "element-text" = {
      vertical-align = mkLiteral "0.5";
      horizontal-align = mkLiteral "0.0";
      cursor = mkLiteral "inherit";
      background-color = mkLiteral "transparent";
      text-color = mkLiteral "inherit";
    };

    message = {
      background-color = mkLiteral background;
      text-color = mkLiteral text;
      border-radius = mkLiteral "15px";
      padding = mkLiteral "0.95em";
    };

    textbox = {
      padding = mkLiteral "0.95em";
      border-radius = mkLiteral "10px";
      background-color = mkLiteral background-alt;
      text-color = mkLiteral text;
      vertical-align = mkLiteral "0.5";
      horizontal-align = mkLiteral "0.0";
    };

    error-message = {
      padding = mkLiteral "0.8em";
      border-radius = mkLiteral "15px";
      background-color = mkLiteral background;
      text-color = mkLiteral text;
    };
  };

  horizontal-theme = {
    background,
    background-alt,
    text,
    selected,
    selected-alt,
    highlight,
    highlight-alt,
    active,
    active-alt,
    urgent,
    urgent-alt,
    icon,
    image,
    font,
  }: {
    "*" = {
      font = "${font.name} ${toString font.size}";
    };

    configuration = {
      show-icons = false;
    };

    window = {
      enabled = true;
      transparency = "real";
      location = mkLiteral "center";
      anchor = mkLiteral "center";
      fullscreen = false;
      x-offset = mkLiteral "0px";
      y-offset = mkLiteral "0px";
      border-radius = mkLiteral "15px";
      background-color = mkLiteral background;
      border = mkLiteral "3px";
      border-color = mkLiteral highlight-alt;
    };

    mainbox = {
      enabled = true;
      spacing = mkLiteral "1em";
      padding = mkLiteral "1em";
      orientation = mkLiteral "vertical";
      children = ["inputbar" "listview" "message"];
      background-color = mkLiteral "transparent";
    };

    dummy = {
      enabled = true;
      background-color = mkLiteral "transparent";
    };

    inputbar = {
      enabled = true;
      spacing = mkLiteral "1.25em";
      border-radius = mkLiteral "1em";
      padding = mkLiteral "5em 2.5em";
      background-color = mkLiteral "transparent";
      background-image = mkLiteral ''url("${image}", width)'';
      orientation = mkLiteral "horizontal";
      children = [
        "dummy"
        "textbox-prompt-colon"
        "prompt"
        "dummy"
      ];
    };

    textbox-prompt-colon = {
      enabled = true;
      expand = false;
      padding = mkLiteral "0.25em 0.75em";
      border-radius = mkLiteral "10px";
      font = "${font.name} ${toString (font.size + 20)}";
      vertical-align = mkLiteral "0.5";
      horizontal-align = mkLiteral "0.5";
      background-color = mkLiteral highlight-alt;
      text-color = mkLiteral background;
      str = icon;
    };

    prompt = {
      enabled = true;
      padding = mkLiteral "0.5em";
      border-radius = mkLiteral "10px";
      vertical-align = mkLiteral "0.5";
      horizontal-align = mkLiteral "0.5";
      background-color = mkLiteral highlight;
      text-color = mkLiteral background-alt;
    };

    mode-switcher = {
      enabled = false;
    };

    listbox = {
      enabled = false;
    };

    listview = {
      enabled = true;
      columns = 6;
      lines = 1;
      cycle = true;
      scrollbar = false;
      layout = mkLiteral "vertical";
      spacing = mkLiteral "1em";
      cursor = "default";
      background-color = mkLiteral "transparent";
    };

    element = {
      enabled = true;
      padding = mkLiteral "1.5em 0.5em";
      border = mkLiteral "1px solid 1px solid 4px solid";
      border-color = mkLiteral text;
      border-radius = mkLiteral "20px";
      cursor = mkLiteral "pointer";
      background-color = mkLiteral background-alt;
      text-color = mkLiteral text;
    };

    "element normal.normal, element alternate.normal" = {
      background-color = mkLiteral background-alt;
      text-color = mkLiteral text;
      border-color = mkLiteral text;
    };

    "element normal.urgent, element alternate.urgent" = {
      text-color = mkLiteral urgent;
      background-color = mkLiteral "inherit";
      border-color = mkLiteral "inherit";
    };

    "element normal.active, element alternate.active" = {
      text-color = mkLiteral active;
      background-color = mkLiteral "inherit";
      border-color = mkLiteral "inherit";
    };

    "element selected.normal" = {
      background-color = mkLiteral selected;
      text-color = mkLiteral background-alt;
      border-color = mkLiteral selected-alt;
    };

    "element selected.urgent" = {
      background-color = mkLiteral urgent;
      text-color = mkLiteral background-alt;
      border-color = mkLiteral urgent-alt;
    };

    "element selected.active" = {
      background-color = mkLiteral active;
      text-color = mkLiteral background-alt;
      border-color = mkLiteral active-alt;
    };

    "element-text" = {
      cursor = mkLiteral "inherit";
      background-color = mkLiteral "transparent";
      text-color = mkLiteral "inherit";
      font = "${font.name} ${toString (font.size + 20)}";
      vertical-align = mkLiteral "0.5";
      horizontal-align = mkLiteral "0.5";
    };

    message = {
      enable = true;
      background-color = mkLiteral background-alt;
      text-color = mkLiteral text;
      border-radius = mkLiteral "10px";
      padding = mkLiteral "0.5em";
    };

    textbox = {
      background-color = mkLiteral "inherit";
      text-color = mkLiteral "inherit";
      vertical-align = mkLiteral "0.5";
      horizontal-align = mkLiteral "0.5";
    };

    error-message = {
      padding = mkLiteral "0.5em";
      border-radius = mkLiteral "15px";
      background-color = mkLiteral background;
      text-color = mkLiteral text;
    };
  };
}
