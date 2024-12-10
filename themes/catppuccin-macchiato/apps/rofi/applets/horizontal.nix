{
  mkLiteral,
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
}
