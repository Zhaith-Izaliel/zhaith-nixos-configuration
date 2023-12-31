{ config, lib, pkgs, theme, ... }:

with lib;

let
  cfg = config.hellebore.shell.emulator;
  kitty-bin = strings.concatStringsSep " " [
    (strings.optionalString cfg.integratedGPU.enable
    "MESA_LOADER_DRIVER_OVERRIDE=${cfg.integratedGPU.driver} __EGL_VENDOR_LIBRARY_FILENAMES=${pkgs.mesa.drivers}/share/glvnd/egl_vendor.d/50_mesa.json")
    "${pkgs.kitty}/bin/kitty"
  ];
in
{
  options.hellebore.shell.emulator = {
    enable = mkEnableOption "Hellebore terminal emulator configuration";

    fontSize = mkOption {
      type = types.int;
      default = config.hellebore.fontSize;
      description = "Set the emulator font size.";
    };

    integratedGPU = {
      enable = mkEnableOption null // {
        description = "Enable Kitty to run on the integrated GPU on a multi GPU
        setup.";
      };
      driver = mkOption {
        type = types.enum [ "i965" "iris" "radeonsi" ];
        default = "";
        description = "Defines the driver to run kitty on a multi GPU setup.";
      };
    };

    bin = mkOption {
      type = types.str;
      default = kitty-bin;
      description = "Get the Kitty binary.";
      readOnly = true;
    };
  };

  config = mkIf cfg.enable ({
    programs.kitty = {
      enable = true;
      inherit (theme.kitty) theme;

      font = {
        package = pkgs.fira-code;
        name = "Fira Code";
        size = cfg.fontSize;
      };

      settings = {
        hide_window_decorations = true;
        background_opacity = "0.9";
        disable_ligatures = "never";
        update_check_interval = 0;
        enabled_layouts = "tall";
        visual_bell_duration = "0";
        enable_audio_bell = false;
        allow_remote_control = true; # Used with vim-kitty
        listen_on = "unix:@mykitty"; # Used with vim-kitty
        linux_display_server = "wayland";
        # Tab Bar
        tab_bar_edge = "bottom";
        tab_bar_align = "left";
        tab_bar_style = "custom";
        tab_bar_min_tabs = 1;
        tab_activity_symbol = "none";
        bell_on_tab = false;
        tab_bar_margin_width = "0.0";
        tab_bar_margin_height = "0.0 0.0";
        tab_title_template = "{f'{title[:20]}…' if title.rindex(title[-1]) + 1 > 30 else (title.center(6) if (title.rindex(title[-1]) + 1) % 2 == 0 else title.center(5))}";
        active_tab_font_style = "bold";
        active_tab_foreground = "black";
        active_tab_background = theme.colors.blue;
        inactive_tab_font_style = "normal";
      };

      keybindings = {
        "ctrl+space>c" = "new_tab";
        "ctrl+space>q" = "close_tab";
        "ctrl+space>t" = "set_tab_title";
        "ctrl+space>;" = "move_tab_forward";
        "ctrl+space>," = "move_tab_backward";
        "ctrl+space>u" = "open_url_with_hints";
        "ctrl+space>enter" = "new_window";
        "ctrl+space>backspace" = "close_window";
        "ctrl+space>s" = "focus_visible_window";
        # Kitten for smart-splits.nvim
        "ctrl+space>down" = "kitten pass_keys.py neighboring_window bottom ctrl+space>down";
        "ctrl+space>up" = "kitten pass_keys.py neighboring_window top ctrl+space>up";
        "ctrl+space>left" = "kitten pass_keys.py neighboring_window left ctrl+space>left";
        "ctrl+space>right" = "kitten pass_keys.py neighboring_window right ctrl+space>right";

        "shift+space>down" = "kitten pass_keys.py relative_resize bottom 3 shift+space>down";
        "shift+space>up" = "kitten pass_keys.py relative_resize top 3 shift+space>up";
        "shift+space>left" = "kitten pass_keys.py relative_resize left 3 shift+space>left";
        "shift+space>right" = "kitten pass_keys.py relative_resize right 3 shift+space>right";

        # Broadcast kitten
        "ctrl+space>b" = "launch --allow-remote-control kitty +kitten broadcast";
        "ctrl+space>h" = "launch --allow-remote-control kitty +kitten broadcast --match-tab state:focused";
      };
    };
  } // (import ../../../assets/kitten { inherit config pkgs lib; }));
}

