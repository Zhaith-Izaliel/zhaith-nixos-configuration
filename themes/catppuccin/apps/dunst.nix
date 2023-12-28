{ colors }:

{
  settings = {
    global = {
      corner_radius = 15;
      frame_color = colors.mauve;
      highlight = colors.mauve;
      separator_color = "frame";
    };

    urgency_low = {
      background = colors.base;
      highlight = colors.sapphire;
      foreground = colors.text;
      frame_color = colors.sapphire;
    };

    urgency_normal = {
      background = colors.base;
      foreground = colors.text;
    };

    urgency_critical = {
      background = colors.base;
      foreground = colors.text;
      frame_color = colors.red;
      highlight = colors.red;
    };

    volume_brightness = {
      frame_color = colors.text;
      foreground = colors.text;
      background = colors.base;
      highlight = colors.text;
    };

    volume_onehundred = {
      highlight = colors.sapphire;
      frame_color = colors.sapphire;
    };

    volume_overamplified = {
      highlight = colors.maroon;
      frame_color = colors.maroon;
    };
  };
}

