{ pkgs, lib, inputs }:

rec {
  package = pkgs.stdenv.mkDerivation rec {
    name = "catppucin-hyprland";
    version = "1.2";

    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "hyprland";
      rev  = "v${version}";
      sha256 = "sha256-07B5QmQmsUKYf38oWU3+2C6KO4JvinuTwmW1Pfk8CT8=";
    };

    installPhase = ''
    mkdir -p $out
    cp -r themes $out
    '';
  };
  palette = "${package}/themes/macchiato.conf";
  theme = ''
  source = ${palette}

  general {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more

    gaps_in = 5
    gaps_out = 20
    border_size = 2
    col.active_border = $mauve $sapphire 45deg
    col.inactive_border = $surface0 0x80$mauveAlpha 45deg

    layout = dwindle
  }

  decoration {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more

    rounding = 10

    blur {
      enabled = true
      size = 3
      passes = 1
      new_optimizations = true
    }

    drop_shadow = true
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = $crust
  }

  animations {
    enabled = true

    # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

    bezier = easeOutCubic, .33, 1, .68, 1
    bezier = easeInOutSine, .37, 0, .63, 1

    animation = windows, 1, 7, easeOutCubic
    animation = windowsOut, 1, 7, easeOutCubic, popin 80%
    animation = windowsIn, 1, 7, easeOutCubic, popin 80%
    animation = border, 1, 3, easeInOutSine
    animation = borderangle, 1, 300, easeInOutSine, loop
    animation = fade, 1, 7, default
    animation = workspaces, 1, 3, easeInOutSine

  }
  '';
}

