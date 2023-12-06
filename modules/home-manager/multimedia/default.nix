{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.hellebore.multimedia;
in
{
  imports = [
    ./art.nix
    ./mpd.nix
    ./obs.nix
  ];

  options.hellebore.multimedia = {
    enable = mkEnableOption "Hellebore's multimedia packages";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      vlc
      kid3
      ffmpeg
      pavucontrol
      blueberry
      power-management
    ];
  };
}

