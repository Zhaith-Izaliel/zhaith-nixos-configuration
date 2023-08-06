{ gtk-theme, colors, lib }:

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
        enable_posix_regex = true;
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

      volume_brightness = {
        summary = "Volume|Brightness";
        history_ignore = true;
        frame_color = colors.text;
        foreground = colors.text;
        background = colors.base;
        highlight = colors.text;
        set_stack_tag = "synchronous";
        timeout = 2;
      };

      volume_icon = {
        summary = "Volume";
        default_icon = toString (lib.cleanSource
        ../../../assets/images/other/volume.png);
      };

      volume_overamplified = {
        msg_urgency = "critical";
        summary = "Volume";
        highlight = colors.maroon;
        frame_color = colors.maroon;
      };

      brightness_icon = {
        summary = "Brightness";
        default_icon = toString (lib.cleanSource
        ../../../assets/images/other/brightness.png);
      };
    };
  };
}

