{ theme-packages, colors }:

let
  gtk-theme = import ./gtk.nix { inherit theme-packages;};
in
{
  dunst = {
    inherit (gtk-theme) iconTheme;

    settings = {
      global = {
        corner_radius = 15;
        font = "${gtk-theme.font.name} ${toString gtk-theme.font.size}";
        frame_color = colors.sapphire;
        separator_color = "frame";
        width = 400;
        height = 400;
      };
      urgency_low = {
        background = colors.base;
        foreground = colors.text;
      };
      urgency_normal = {
        background = colors.base;
        foreground = colors.text;
      };
      urgency_critical = {
        background = colors.base;
        foreground = colors.text;
        frame_color = colors.red;
      };
    };
  };
}

