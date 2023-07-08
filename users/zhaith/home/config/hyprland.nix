{ pkgs, inputs, common-attrs, ... }:

let
  gtk-theme = common-attrs.gtk-theme;
  hyprland-config = import  ../../../../assets/hyprland/default.nix { inherit pkgs; };
  anyrun-plugins = inputs.anyrun.packages.${pkgs.system};
in
{
  home.packages = with pkgs; [
    hyprpicker
    swww
    swayosd
  ];

  gtk = {
    enable = true;
    inherit (gtk-theme) theme cursorTheme iconTheme font;

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  services.dunst = {
    enable = true;
    inherit (gtk-theme) iconTheme;
    settings = {
      global = {
        corner_radius = 15;
        font = "${gtk-theme.font.name} ${toString gtk-theme.font.size}";
        frame_color = "#7DC4E4";
        separator_color = "frame";
      };
      urgency_low = {
        background = "#24273A";
        foreground = "#CAD3F5";
      };
      urgency_normal = {
        background = "#24273A";
        foreground = "#CAD3F5";
      };
      urgency_critical = {
        background = "#24273A";
        foreground = "#CAD3F5";
        frame_color = "#ED8796";
      };
    };
  };

  programs.anyrun = {
    enable = true;
    config = {
      plugins = with anyrun-plugins; [
        applications
        rink
        translate
        randr
        dictionary
      ];
      width = { fraction = 0.5; };
      height = { fraction = 0.5; };
      x = { fraction = 0.5; };
      y = { fraction = 0.5; };
      hideIcons = false;
      ignoreExclusiveZones = true;
      layer = "overlay";
      hidePluginInfo = true;
      closeOnClick = true;
      showResultsImmediately = true;
      maxEntries = 5;
    };
    extraCss = ''
      window:after {
        opacity: 0.5;
      }
    '';
    extraConfigFiles."applications.ron".text = ''
      Config(
        desktop_actions = true,
        max_entries = 5,
        terminal: Some("kitty"),
      )
    '';
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
      hidpi = true;
    };
    systemdIntegration = true;
    recommendedEnvironment = true;
    plugins = with pkgs; [
    ];
    extraConfig = hyprland-config.config;
  };
}

