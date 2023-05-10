{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vlc
    kid3
    ffmpeg
    input-remapper
  ];
}
