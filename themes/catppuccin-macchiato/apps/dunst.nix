{colors}: {
  settings = {
    global = {
      corner_radius = 15;
      frame_color = colors.normal.mauve;
      highlight = colors.normal.mauve;
      separator_color = "frame";
    };

    urgency_low = {
      background = colors.normal.base;
      highlight = colors.normal.sapphire;
      foreground = colors.normal.text;
      frame_color = colors.normal.sapphire;
    };

    urgency_normal = {
      background = colors.normal.base;
      foreground = colors.normal.text;
    };

    urgency_critical = {
      background = colors.normal.base;
      foreground = colors.normal.text;
      frame_color = colors.normal.red;
      highlight = colors.normal.red;
    };

    volume_brightness = {
      frame_color = colors.normal.text;
      foreground = colors.normal.text;
      background = colors.normal.base;
      highlight = colors.normal.text;
    };

    volume_onehundred = {
      highlight = colors.normal.sapphire;
      frame_color = colors.normal.sapphire;
    };

    volume_overamplified = {
      highlight = colors.normal.maroon;
      frame_color = colors.normal.maroon;
    };
  };
}
