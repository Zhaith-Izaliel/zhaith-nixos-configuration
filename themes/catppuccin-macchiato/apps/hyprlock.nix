{
  palette,
  colors,
  lib,
  pkgs,
}: let
  inherit (lib) mapAttrs;
  converted-colors = mapAttrs (name: value: "#${value}") colors.normal; # This escapes `#` to allow colors in `span`.

  shadowConfig = {
    shadow_passes = 3;
    shadow_size = 8;
    shadow_color = "$crust";
    shadow_boost = 1.5;
  };
in {
  extraPackages = with pkgs; [
    wttrbar
    jq
  ];

  settings = {
    font,
    backgroundImage ? "screenshot",
  }: {
    source = [palette];

    background = {
      monitor = "";
      path = backgroundImage;
      blur_size = 3;
      blur_passes = 6;
      noise = 0.0117;
      contrast = 1.3000; # Vibrant
      brightness = 0.8000;
      vibrancy = 0.2100;
      vibrancy_darkness = 0.0;
    };

    label = builtins.map (item: item // shadowConfig) [
      {
        monitor = "";
        text = ''cmd[update:1000] echo "<big>$(date +"%H:%M")</big>"'';
        color = "$lavender";
        font_size = 64;
        font_family = font.name;
        position = "0, 100";
        halign = "center";
        valign = "center";
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
      }
      {
        monitor = "";
        text = ''cmd[update:1000] wttrbar --custom-indicator "{ICON} {temp_C}°C ({FeelsLikeC}°C)" | jq -r .text'';
        color = "$text";
        font_size = font.size - 5;
        font_family = font.name;
        position = "25, 25";
        halign = "left";
        valign = "bottom";
      }
    ];

    input-field = {
      monitor = "";
      size = "300, 40";
      outline_thickness = 1;
      dots_size = 0.2; # Scale of input-field height, 0.2 - 0.8
      dots_spacing = 0.50; # Scale of dots' absolute size, 0.0 - 1.0
      dots_center = true;
      outer_color = "$sapphire";
      inner_color = "$crust";
      font_color = "$text";
      capslock_color = "$peach";
      numlock_color = "$teal";
      bothlock_color = "$pink"; # when both locks are active. -1 means don't change outer color (same for above)
      fail_color = "$maroon";
      check_color = "$sapphire";
      fade_on_empty = false;
      rounding = -1;
      placeholder_text = "<i>Input Password...</i>"; # Text rendered in the input box when it's empty.
      hide_input = false;
      position = "0, -100";
      halign = "center";
      valign = "center";
    };
  };
}
