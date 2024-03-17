{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hellebore.multimedia;
in {
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
      mpv
      vlc
      kid3
      ffmpeg
    ];
  };
}
