{ config, pkgs, lib, ... }:

let
  kittens = import ./kitten.nix { inherit pkgs lib; };
in
{
  home.packages = with pkgs; [
    tdrop
  ];

  programs = {
    kitty = {
      enable = true;
      theme = "Catppuccin-Macchiato";
      font = {
        package = pkgs.fira-code;
        name = "Fira Code";
        size = 14;
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
        # Tab Bar
        tab_bar_edge = "bottom";
        tab_bar_align = "left";
        tab_bar_style = "custom";
        tab_bar_min_tabs = 1;
        tab_activity_symbol = "none";
        bell_on_tab = false;
        tab_bar_margin_width = "0.0";
        tab_bar_margin_height = "0.0 0.0";
        tab_title_template = "{f'{title[:30]}…' if title.rindex(title[-1]) + 1 > 30 else (title.center(6) if (title.rindex(title[-1]) + 1) % 2 == 0 else title.center(5))}";
        active_tab_font_style = "bold";
        active_tab_foreground = "black";
        active_tab_background = "#8aadf4";
        inactive_tab_font_style = "normal";
      };

      keybindings = {
        "ctrl+space>c" = "new_tab";
        "ctrl+space>n" = "next_tab";
        "ctrl+space>p" = "previous_tab";
        "ctrl+space>q" = "close_tab";
        "ctrl+space>t" = "set_tab_title";
        "ctrl+space>;" = "move_tab_forward";
        "ctrl+space>," = "move_tab_backward";
        "ctrl+space>u" = "open_url_with_hints";
        "ctrl+space>enter" = "new_window";
        "ctrl+space>backspace" = "close_window";
        "ctrl+space>s" = "focus_visible_window";
        # Kitten for vim-kitty-navigator
        "ctrl+space>down" = "kitten pass_keys.py neighboring_window bottom ctrl+space>down";
        "ctrl+space>up" = "kitten pass_keys.py neighboring_window top ctrl+space>up";
        "ctrl+space>left" = "kitten pass_keys.py neighboring_window left ctrl+space>left";
        "ctrl+space>right" = "kitten pass_keys.py neighboring_window right ctrl+space>right";
        # Broadcast kitten
        "ctrl+space>b" = "launch --allow-remote-control kitty +kitten broadcast";
        "ctrl+space>h" = "launch --allow-remote-control kitty +kitten broadcast --match-tab state:focused";
      };
    };
  };

  services.sxhkd = {
    enable = true;
    keybindings = {
      "super + shift + t" = "${pkgs.tdrop}/bin/tdrop -ma -h 100% -w 100% kitty --start-as fullscreen";
    };
  };

  # NOTE: Used in tandem with sxhkd to work with its enable option.
  xsession.enable = true;

  # HACK: Adding kittens
  home.file = {
    ".config/kitty/pass_keys.py".source = "${kittens.vim-kitty-navigator}/pass_keys.py";
    ".config/kitty/neighboring_window.py".source = "${kittens.vim-kitty-navigator}/neighboring_window.py";
    ".config/kitty/tab_bar.py".source = lib.cleanSource ./tab_bar.py;
  };
}