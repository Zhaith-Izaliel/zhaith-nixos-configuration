{
  pkgs,
  lib,
  inputs,
}: rec {
  package = pkgs.stdenvNoCC.mkDerivation {
    name = "catppucin-hyprland";
    version = inputs.catppuccin-hyprland.rev;

    src = inputs.catppuccin-hyprland;

    installPhase = ''
      mkdir -p $out
      cp -r themes $out
    '';
  };

  palette = "${package}/themes/macchiato.conf";

  settings = {
    source = [
      palette
    ];

    general = {
      gaps_in = 5;
      gaps_out = 20;
      border_size = 2;
      "col.active_border" = "$mauve $sapphire 45deg";
      "col.inactive_border" = "$surface0 0x80$mauveAlpha 45deg";
    };

    decoration = {
      rounding = 10;

      blur = {
        enabled = true;
        size = 3;
        passes = 4;
        new_optimizations = true;
        noise = 0.0117;
        contrast = 1.3000; # Vibrant
        brightness = 0.8000;
        vibrancy = 0.2100;
        vibrancy_darkness = 0.0;
      };

      shadow = {
        enabled = true;
        range = 4;
        render_power = 3;
        color = "$crust";
      };
    };

    animations = {
      enabled = true;

      bezier = [
        "easeOutCubic, .33, 1, .68, 1"
        "easeInOutSine, .37, 0, .63, 1"
      ];

      animation = [
        "windows, 1, 7, easeOutCubic"
        "windowsOut, 1, 7, easeOutCubic, popin 80%"
        "windowsIn, 1, 7, easeOutCubic, popin 80%"
        "border, 1, 3, easeInOutSine"
        "borderangle, 1, 300, easeInOutSine, loop"
        "fade, 1, 7, default"
        "workspaces, 1, 3, easeInOutSine"
      ];
    };

    plugin.scroller = {
      jump_labels_color = "$teal";
      "col.selection_border" = "$peach";
    };
  };
}
