{ theme-packages }:

{
  package = theme-packages.fcitx5-theme;

  fcitx5 = {
    theme = {
      xdgConfigFile = "fcitx5/conf/classicui.conf";
      content = ''
        Theme=catppuccin-macchiato
      '';
    };
  };
}

