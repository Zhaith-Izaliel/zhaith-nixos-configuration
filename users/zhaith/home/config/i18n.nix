{ pkgs, theme, ... }:

let
  fcitx5-theme = theme.fcitx5-theme.fcitx5.theme;
in
{
  home.packages = [
    theme.fcitx5-theme.package
  ];

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      fcitx5-anthy
    ];
  };

  xdg.configFile."${fcitx5-theme.xdgConfigFile}" = {
    source = pkgs.writeText fcitx5-theme.xdgConfigFile fcitx5-theme.content;
  };
}

