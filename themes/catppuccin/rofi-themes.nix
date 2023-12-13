{ colors }:

let
  mkLiteral = str: str;
in
  {
    vertical-applet-theme = {
      configuration = {
        show-icons = false;
      };

      "*" = {
        font= "NotoMono Nerd Font 14";
        background = mkLiteral "#11092D";
        background-alt = mkLiteral "#281657";
        foreground = mkLiteral "#FFFFFF";
        selected = mkLiteral "#DF5296";
        active = mkLiteral "#6E77FF";
        urgent = mkLiteral "#8E3596";
      };

      window = {
        transparency = "real";
        location = mkLiteral "center";
        anchor = mkLiteral "center";
        fullscreen = false;
        height = mkLiteral "400px";
        width = mkLiteral "600px";
        x-offset = mkLiteral "0px";
        y-offset = mkLiteral "0px";
        margin = mkLiteral "0px";
        padding = mkLiteral "0px";
        border = mkLiteral "0px solid";
        border-radius = mkLiteral "20px";
        border-color = mkLiteral "@selected";
        cursor = "default";
        background-color = mkLiteral "@background";
      };

      mainbox = {
        enabled = true;
        spacing = mkLiteral "15px";
        margin = mkLiteral "0px";
        padding = mkLiteral "30px";
        background-color = mkLiteral "transparent";
        orientation = mkLiteral "horizontal";
        children = [ "imagebox" "listview" ];
      };

      imagebox = {
        border-radius = mkLiteral "20px";
        background-color = mkLiteral "transparent";
        background-image = mkLiteral
        ''url("/home/zhaith/Development/gitlab.com/Zhaith-Izaliel/rofi-applets/assets/j.jpg",
        height)'';
        children = [ "dummy" "inputbar" "dummy" ];
      };

      inputbar = {
        enabled = true;
        spacing = mkLiteral "15px";
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@foreground";
        children = [ "dummy" "textbox-prompt-colon" "prompt" "dummy"];
      };

      dummy = {
        background-color = mkLiteral "transparent";
      };

      textbox-prompt-colon = {
        enabled = true;
        expand = false;
        str = "";
        padding = mkLiteral "10px 13px";
        border-radius = mkLiteral "15px";
        background-color = mkLiteral "@urgent";
        text-color = mkLiteral "@foreground";
      };

      prompt = {
        enabled = true;
        padding = mkLiteral "10px";
        border-radius = mkLiteral "15px";
        background-color = mkLiteral "@active";
        text-color = mkLiteral "@background";
      };

      message = {
        enabled = true;
        margin = mkLiteral "0px";
        padding = mkLiteral "10px";
        border = mkLiteral "0px solid";
        border-radius = mkLiteral "0px";
        border-color = mkLiteral "@selected";
        background-color = mkLiteral "@background-alt";
        text-color = mkLiteral "@foreground";
      };

      textbox = {
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
        vertical-align = 0.5;
        horizontal-align = 0.0;
      };

      listview = {
        enabled = true;
        columns = 6;
        lines = 1;
        cycle = true;
        scrollbar = false;
        layout = mkLiteral "vertical";
        spacing = mkLiteral "5px";
        background-color = mkLiteral "transparent";
        cursor = "default";
      };

      element = {
        enabled = true;
        padding = mkLiteral "10px";
        border = mkLiteral "0px solid";
        border-radius = mkLiteral "15px";
        border-color = mkLiteral "@selected";
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@foreground";
        cursor = mkLiteral "pointer";
      };

      element-text = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "inherit";
        cursor = mkLiteral "inherit";
        vertical-align = 0.5;
        horizontal-align = 0.0;
      };

      "element normal.normal,element alternate.normal" = {
        background-color = mkLiteral "var(background)";
        text-color = mkLiteral "var(foreground)";
      };

      "element normal.urgent,element alternate.urgent,element selected.active" = {
        background-color = mkLiteral "var(urgent)";
        text-color = mkLiteral "var(background)";
      };

      "element normal.active,element alternate.active,element selected.urgent" = {
        background-color = mkLiteral "var(active)";
        text-color = mkLiteral "var(background)";
      };

      "element selected.normal" = {
        background-color = mkLiteral "var(selected)";
        text-color = mkLiteral "var(background)";
      };
    };
  }

