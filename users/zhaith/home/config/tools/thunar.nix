{ pkgs, ... }:

{
  home.packages = with pkgs; [
    xfce.thunar
    xfce.thunar-volman
    xfce.thunar-media-tags-plugin
  ];
}

