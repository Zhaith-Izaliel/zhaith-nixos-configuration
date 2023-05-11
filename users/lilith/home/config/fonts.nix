{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    noto-fonts-cjk-sans
    twitter-color-emoji
    powerline-fonts
    cantarell-fonts
    ubuntu_font_family
    nerdfonts
    fira-code
    fira-code-symbols
    terminus_font
  ];

  fonts.fontconfig.enable = true;
}