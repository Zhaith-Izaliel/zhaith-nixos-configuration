{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.hellebore.multimedia;
in
{
  options.hellebore.multimedia = {
    enable = mkEnableOption "Hellebore's multimedia packages";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      vlc
      kid3
      ffmpeg
      input-remapper
      pavucontrol
      blueberry
      power-management
    ];
  };
}

