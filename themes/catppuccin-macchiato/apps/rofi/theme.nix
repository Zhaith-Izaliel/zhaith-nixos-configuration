{
  colors,
  mkLiteral,
  image,
}: {
  window = {
    transparency = "real";
    location = mkLiteral "center";
    anchor = mkLiteral "center";
    fullscreen = false;
    x-offset = mkLiteral "0px";
    y-offset = mkLiteral "0px";
    enabled = true;
    border-radius = mkLiteral "15px";
    background-color = mkLiteral colors.normal.base;
    border = mkLiteral "3px";
    border-color = mkLiteral colors.normal.mauve;
  };

  mainbox = {
    enabled = true;
    spacing = mkLiteral "0px";
    orientation = mkLiteral "horizontal";
    children = ["imagebox" "listbox"];
    background-color = mkLiteral "transparent";
  };

  imagebox = {
    enabled = true;
    padding = mkLiteral "1.25em";
    background-color = mkLiteral "transparent";
    background-image = mkLiteral ''url("${image}", height)'';
    orientation = mkLiteral "vertical";
    children = ["inputbar" "dummy" "mode-switcher"];
  };

  listbox = {
    enabled = true;
    spacing = mkLiteral "1.25em";
    padding = mkLiteral "1.25em";
    children = ["message" "listview"];
    orientation = mkLiteral "vertical";
    background-color = mkLiteral "transparent";
  };

  dummy = {
    enabled = true;
    background-color = mkLiteral "transparent";
  };

  inputbar = {
    enabled = true;
    padding = mkLiteral "0.75em";
    spacing = mkLiteral "0.5em";
    border-radius = mkLiteral "10px";
    background-color = mkLiteral colors.normal.crust;
    border-color = mkLiteral colors.normal.blue;
    border = mkLiteral "2px";
    text-color = mkLiteral colors.normal.text;
    children = ["textbox-prompt-colon" "entry"];
  };

  textbox-prompt-colon = {
    enabled = true;
    expand = false;
    str = " ";
    background-color = mkLiteral "inherit";
    text-color = mkLiteral "inherit";
  };

  entry = {
    enabled = true;
    background-color = mkLiteral colors.normal.crust;
    text-color = mkLiteral "inherit";
    cursor = mkLiteral "text";
    placeholder = "Search";
    placeholder-color = mkLiteral "inherit";
  };

  mode-switcher = {
    enabled = true;
    background-color = mkLiteral "transparent";
    text-color = mkLiteral colors.normal.text;
    spacing = mkLiteral "1.25em";
  };

  button = {
    padding = mkLiteral "0.95em";
    cursor = mkLiteral "pointer";
    font-style = mkLiteral "bold";
    border-radius = mkLiteral "10px";
    border = mkLiteral "2px";
    border-color = mkLiteral colors.normal.blue;
    background-color = mkLiteral colors.normal.crust;
    text-color = mkLiteral "inherit";
  };

  "button selected" = {
    background-color = mkLiteral colors.normal.lavender;
    text-color = mkLiteral colors.normal.base;
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
    text-color = mkLiteral colors.normal.text;
  };

  element = {
    enabled = true;
    spacing = mkLiteral "0.95em";
    padding = mkLiteral "0.5em";
    border-radius = mkLiteral "10px";
    cursor = mkLiteral "pointer";
    background-color = mkLiteral "transparent";
    text-color = mkLiteral colors.normal.text;
  };

  "element normal.normal, element alternate.normal" = {
    background-color = mkLiteral "inherit";
    text-color = mkLiteral "inherit";
  };

  "element normal.urgent, element alternate.urgent" = {
    text-color = mkLiteral colors.normal.maroon;
    background-color = mkLiteral "transparent";
  };

  "element normal.active, element alternate.active" = {
    text-color = mkLiteral colors.normal.mauve;
    background-color = mkLiteral "transparent";
  };

  "element selected.normal" = {
    background-color = mkLiteral colors.normal.lavender;
    text-color = mkLiteral colors.normal.base;
  };

  "element selected.urgent" = {
    background-color = mkLiteral colors.normal.maroon;
    text-color = mkLiteral colors.normal.base;
  };

  "element selected.active" = {
    background-color = mkLiteral colors.normal.mauve;
    text-color = mkLiteral colors.normal.base;
  };

  "element-icon" = {
    size = mkLiteral "1.7em";
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
    background-color = mkLiteral colors.normal.crust;
    text-color = mkLiteral colors.normal.text;
    vertical-align = mkLiteral "0.5";
    horizontal-align = mkLiteral "0.5";
  };

  error-message = {
    padding = mkLiteral "0.8em";
    border-radius = mkLiteral "15px";
    background-color = mkLiteral colors.normal.crust;
    text-color = mkLiteral colors.normal.text;
  };
}
