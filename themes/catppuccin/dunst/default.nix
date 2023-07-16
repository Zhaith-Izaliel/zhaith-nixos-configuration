{ gtk-theme, colors }:

{
  dunst = {
    inherit (gtk-theme) iconTheme;

    settings = {
      global = {
        corner_radius = 15;
        font = "${gtk-theme.font.name} ${toString gtk-theme.font.size}";
        frame_color = colors.mauve;
        separator_color = "frame";
        width = 400;
        height = 400;
      };
      urgency_low = {
        background = colors.base;
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
      };
    };
  };
}

