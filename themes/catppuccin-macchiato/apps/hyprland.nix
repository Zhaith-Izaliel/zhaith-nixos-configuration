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
      };

      drop_shadow = true;
      shadow_range = 4;
      shadow_render_power = 3;
      "col.shadow" = "$crust";
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
  };
}
