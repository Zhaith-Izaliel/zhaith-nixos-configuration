{
  palette,
  colors,
  lib,
}: let
  inherit (lib) mapAttrs;
  converted-colors = mapAttrs (name: value: "#${value}") colors.normal; # This escapes `#` to allow colors in `span`.
in {
  settings = {
    font,
    backgroundImage ? "screenshot",
  }: {
    source = [palette];

    background = {
      monitor = "";
      path = backgroundImage;
      blur_size = 3;
      blur_passes = 4;
      noise = 0.0117;
      contrast = 1.3000; # Vibrant
      brightness = 0.8000;
      vibrancy = 0.2100;
      vibrancy_darkness = 0.0;
    };

    label = [
      {
        monitor = "";
        text = ''cmd[update:1000] echo "<big>$(date +"%H:%M")</big>"'';
        color = "$lavender";
        font_size = 64;
        font_family = font.name;
        position = "0, 100";
        halign = "center";
        valign = "center";
        shadow_passes = 2;
        shadow_size = 5;
        shadow_color = "$crust";
      }
      {
        monitor = "";
        text = ''Welcome, <span color="${converted-colors.mauve}" style="italic">$DESC</span>'';
        color = "$text";
        font_size = font.size;
        font_family = font.name;
        position = "0, 0";
        halign = "center";
        valign = "center";
        shadow_passes = 2;
        shadow_size = 5;
        shadow_color = "$crust";
      }
    ];

    input-field = {
      monitor = "";
      size = "300, 50";
      outline_thickness = 1;
      dots_size = 0.2; # Scale of input-field height, 0.2 - 0.8
      dots_spacing = 1.00; # Scale of dots' absolute size, 0.0 - 1.0
      dots_center = true;
      outer_color = "$sapphire";
      inner_color = "$crust";
      font_color = "$text";
      fade_on_empty = true;
      placeholder_text = "<i>Password...</i>"; # Text rendered in the input box when it's empty.
      hide_input = false;
      position = "0, -100";
      halign = "center";
      valign = "center";
    };
  };
}
