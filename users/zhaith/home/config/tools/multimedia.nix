{ pkgs, ... }:

{
  home.packages = with pkgs; [
    vlc
    kid3
    ffmpeg
    input-remapper
    pavucontrol
  ];
}

