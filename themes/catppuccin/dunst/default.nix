{ gtk-theme, colors }:

{
  dunst = {
    inherit (gtk-theme) iconTheme;

    settings = {
      global = {
        corner_radius = 15;
        font = "${gtk-theme.font.name} ${toString gtk-theme.font.size}";
        frame_color = colors.mauve;
        highlight = colors.mauve;
        separator_color = "frame";
        width = 400;
        height = 400;
        progress_bar = true;
      };
      volume = {
        summary = "Volume";
        history_ignore = true;
        default_icon = ../../../assets/images/other/volume.png;
        frame_color = colors.text;
        foreground = colors.text;
        background = colors.base;
        highlight = colors.text;
        set_stack_tag = "synchronous";
      };
      volume_overamplified = {
        urgency = "critical";
        summary = "Volume";
        highlight = colors.maroon;
        frame_color = colors.maroon;
        timeout = 10;
      };
      brightness = {

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
        frame_color = colors.maroon;
        highlight = colors.maroon;
      };
    };
  };
}

