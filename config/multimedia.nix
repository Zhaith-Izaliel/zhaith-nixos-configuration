{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vlc
    kid3
    ffmpeg
  ];

  hardware = {
    pulseaudio = {
      enable = true;
      extraConfig = ''
        load-module module-switch-on-connect
      '';
    };
    bluetooth.enable = true;
  };
}