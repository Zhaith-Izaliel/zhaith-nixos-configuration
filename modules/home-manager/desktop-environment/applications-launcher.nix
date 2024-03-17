{
  os-config,
  config,
  lib,
  pkgs,
  extra-types,
  ...
}: let
  inherit (config.lib.formats.rasi) mkLiteral;
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    optionalString
    recursiveUpdate
    ;

  cfg = config.hellebore.desktop-environment.applications-launcher;
  theme = config.hellebore.theme.themes.${cfg.theme};
  rofi-theme = theme.rofi mkLiteral;

  moduleTheme = {
    width,
    height,
  }: {
    window = {
      cursor = theme.gtk.cursorTheme.name;
      width = mkLiteral width;
      height = mkLiteral height;
    };
  };

  width = mkOption {
    type = types.nonEmptyStr;
    default = "1600px";
    description = "Defines the width of the window.";
  };

  height = mkOption {
    type = types.nonEmptyStr;
    default = "700px";
    description = "Defines the height of the window.";
  };

  applets-submodule = name: {
    inherit width height;

    font = extra-types.font {
      size = cfg.font.size;
      name = cfg.font.name;
      nameDescription = "Defines the applet's font family.";
      sizeDescription = "Defines the applet's font size to scale the UI on.";
    };

    package = mkOption {
      type = types.package;
      default = config.programs.rofi.applets.${name}.package;
      description = "Defines the package of the applet.";
    };
  };

  mkAppletTheme = name: let
    theme = rofi-theme.applets.${name} {
      inherit (cfg.applets.${name}) font;
    };
    generatedModuleTheme = moduleTheme {
      inherit (cfg.applets.${name}) width height;
    };
  in
    recursiveUpdate theme generatedModuleTheme;
in {
  options.hellebore.desktop-environment.applications-launcher = {
    inherit width height;

    enable = mkEnableOption "Hellebore Applications Launcher configuration";

    font = extra-types.font {
      size = config.hellebore.font.size;
      name = "FiraMono Nerd Font Mono";
      nameDescription = "Defines the font family used on the
      applications launcher.";
      sizeDescription = "Defines the font size used on the
      applications launcher to scale the UI on.";
    };

    command = mkOption {
      type = types.str;
      default = "${config.programs.rofi.finalPackage}/bin/rofi -show drun";
      readOnly = true;
      description = "The command to show the applications launcher.";
    };

    theme = extra-types.theme.name {
      default = config.hellebore.theme.name;
      description = "The applications launcher theme to use. Default to global
      theme.";
    };

    applets = {
      favorites = applets-submodule "favorites";
      bluetooth = applets-submodule "bluetooth";
      quicklinks = applets-submodule "quicklinks";
      network-manager = applets-submodule "network-manager";
      mpd = applets-submodule "mpd";
      power-profiles = applets-submodule "power-profiles";
    };
  };

  config = mkIf cfg.enable {
    programs.rofi = {
      enable = true;

      package = pkgs.rofi-wayland;

      font = "${cfg.font.name} ${toString cfg.font.size}";

      terminal =
        optionalString
        config.hellebore.shell.emulator.enable
        config.hellebore.shell.emulator.bin;

      plugins = with pkgs; [
        rofi-calc
      ];

      extraConfig = {
        # modi = "drun,calc";
        modi = "drun";
        show-icons = true;
        display-drun = " Apps";
        display-calc = "󰲒 Calc";
        drun-display-format = "{name}";
        icon-theme = theme.gtk.iconTheme.name;
        window-format = "{w} · {c} · {t}";
      };

      theme =
        recursiveUpdate
        rofi-theme.theme
        (moduleTheme {inherit (cfg) width height;});

      applets = {
        bluetooth = {
          enable = os-config.hardware.bluetooth.enable;
          settings = {
            divider = "────────────────────────────────────";
            go_back_text = "↩ Back";
            scan_on_text = "󰂰 Scan: On";
            scan_off_text = "󰂰 Scan: Off";
            scanning_text = "󰂰 Scanning...";
            pairable_on_text = "󰌷 Pairable: On";
            pairable_off_text = "󰌸 Pairable: Off";
            discoverable_on_text = " Discoverable: On";
            discoverable_off_text = " Discoverable: Off";
            power_on_text = "󰂯 Power: On";
            power_off_text = "󰂲 Power: Off";
            trusted_yes_text = " Trusted: Yes";
            trusted_no_text = " Trusted: No";
            connected_yes_text = "󰂱 Connected: Yes";
            connected_no_text = "󰂳 Connected: No";
            paired_yes_text = "󰲔 Paired: Yes";
            paired_no_text = "󱂺 Paired: No";
            no_option_text = "No option chosen.";
            exit_text = "󰗼 Exit";
          };
          theme = mkAppletTheme "bluetooth";
        };

        quicklinks = {
          enable = true;
          settings = {
            quicklinks = {
              "" = "https://nextcloud.ethereal-edelweiss.cloud/apps/dashboard/#/";
              "󰼁" = "https://jellyfin.ethereal-edelweiss.cloud";
              "" = "https://devdocs.io/";
              "" = "https://github.com/";
              "" = "https://gitlab.com/";
              "" = "http://www.youtube.com/";
              "" = "https://www.reddit.com/";
            };

            order = [
              ""
              "󰼁"
              ""
              ""
              ""
              ""
              ""
            ];
            exit_text = "󰗼";
          };
          theme = mkAppletTheme "quicklinks";
        };

        favorites = {
          enable = true;
          settings = {
            favorites = {
              "" = "kitty";
              "" = "nemo";
              "󰖟" = "firefox";
              "󰤌" = "kitty -e nvim";
              "󰽴" = "kitty -e ncmpcpp";
            };
            order = [
              ""
              ""
              "󰤌"
              "󰖟"
              "󰽴"
            ];
            exit_text = "󰗼";
          };
          theme = mkAppletTheme "favorites";
        };

        mpd = {
          enable = config.services.mpd.enable;
          theme = mkAppletTheme "mpd";
          settings = {
            stop_text = "";
            next_text = "󰒭";
            previous_text = "󰒮";
            repeat_text = "";
            random_text = "";
            pause_text = "";
            play_text = "";
            parse_error_text = "";
            no_song_text = "󰟎";
            previous_notification_text = "Playing";
            next_notification_text = "Playing";
            play_notification_text = "Playing";
            pause_notification_text = "Pausing";
          };
        };

        network-manager = {
          enable = os-config.networking.networkmanager.enable;
          theme = mkAppletTheme "network-manager";
          settings = {
            notifications = "true";
            ascii_out = true;
            width_fix_main = 100;
          };
        };

        power-profiles = {
          enable = os-config.services.power-profiles-daemon.enable;
          theme = mkAppletTheme "power-profiles";
          settings = {
            exit_text = "󰗼";
            performance_text = "󰓅";
            balanced_text = "󰾅";
            power_saver_text = "󰾆";
          };
        };
      };
    };
  };
}
