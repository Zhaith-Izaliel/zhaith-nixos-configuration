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

  programs.swaylock = {
    enable = true;
    settings = {
      color = "24273a";
      bs-hl-color= "f4dbd6";
      caps-lock-bs-hl-color = "f4dbd6";
      caps-lock-key-hl-color="a6da95";
      inside-color = "24273a";
      inside-clear-color = "24273a";
      inside-caps-lock-color = "24273a";
      inside-ver-color = "24273a";
      inside-wrong-color = "24273a";
      key-hl-color = "a6da95";
      layout-bg-color = "00000000";
      layout-border-color = "00000000";
      layout-text-color = "cad3f5";
      line-color = "00000000";
      line-clear-color="00000000";
      line-caps-lock-color="00000000";
      line-ver-color="00000000";
      line-wrong-color="00000000";
      ring-color="b7bdf8";
      ring-clear-color="f4dbd6";
      ring-caps-lock-color="f5a97f";
      ring-ver-color="8aadf4";
      ring-wrong-color="ee99a0";
      separator-color="00000000";
      text-color="cad3f5";
      text-clear-color="f4dbd6";
      text-caps-lock-color="f5a97f";
      text-ver-color="8aadf4";
      text-wrong-color="ee99a0";
      font-size = gtk-theme.font.size;
      font = gtk-theme.font.name;
      indicator-caps-lock = true;
      image = "/home/zhaith/Pictures/Wallpapers/Nord/cats.png";
    };
  };

  services.swayidle = {
    enable = true;
    timeouts = [
      { timeout = 300; command = "${pkgs.swaylock}/bin/swaylock -fF"; }
      {
        timeout = 600;
        command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
        resumeCommand = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      }
    ];
    events = [
      { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock -fF"; }
    ];
    extraArgs = [
      "-w"
    ];
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

