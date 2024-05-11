{colors}: rec {
  name = "catppuccin_macchiato";

  theme = {
    ${name} = {
      default = {
        background = colors.normal.base;
        foreground = colors.normal.text;
      };
      cursor = {
        default = colors.normal.rosewater;
        text = colors.normal.base;
      };
      normal = {
        black = colors.normal.surface1;
        red = colors.normal.red;
        green = colors.normal.green;
        yellow = colors.normal.yellow;
        blue = colors.normal.blue;
        magenta = colors.normal.pink;
        cyan = colors.normal.teal;
        white = colors.normal.subtext1;
      };
      bright = {
        black = colors.normal.surface2;
        red = colors.normal.red;
        green = colors.normal.green;
        yellow = colors.normal.yellow;
        blue = colors.normal.blue;
        magenta = colors.normal.pink;
        cyan = colors.normal.teal;
        white = colors.normal.subtext0;
      };
    };
  };
}
