{ pkgs, colors }:

{
  kitty = {
    theme = "Catppuccin-Macchiato";

    font = {
      package = pkgs.fira-code;
      name = "Fira Code";
      size = 12;
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
      tab_title_template = "{f'{title[:30]}…' if title.rindex(title[-1]) + 1 > 30 else (title.center(6) if (title.rindex(title[-1]) + 1) % 2 == 0 else title.center(5))}";
      active_tab_font_style = "bold";
      active_tab_foreground = "black";
      active_tab_background = colors.blue;
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
      "space+down" = "kitten pass_keys.py neighboring_window bottom space+down";
      "space+up" = "kitten pass_keys.py neighboring_window top space+up";
      "space+left" = "kitten pass_keys.py neighboring_window left space+left";
      "space+right" = "kitten pass_keys.py neighboring_window right space+right";

      "space+shift+down" = "kitten pass_keys.py relative_resize bottom 3 space+shift+down";
      "space+shift+up" = "kitten pass_keys.py relative_resize top 3 space+shift+up";
      "space+shift+left" = "kitten pass_keys.py relative_resize left 3 space+shift+left";
      "space+shift+right" = "kitten pass_keys.py relative_resize right 3 space+shift+right";

      # Broadcast kitten
      "ctrl+space>b" = "launch --allow-remote-control kitty +kitten broadcast";
      "ctrl+space>h" = "launch --allow-remote-control kitty +kitten broadcast --match-tab state:focused";
    };
  };
}

