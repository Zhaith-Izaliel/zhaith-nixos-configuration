{
  config,
  lib,
  pkgs,
  stable-pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hellebore.multimedia;
in {
  imports = [
    ./art.nix
    ./mpd.nix
    ./obs.nix
    ./sonobus.nix
  ];

  options.hellebore.multimedia = {
    enable = mkEnableOption "Hellebore's multimedia packages";

    mpris.enable = mkEnableOption "MPRIS support";
  };

  config = mkIf cfg.enable {
    home.packages =
      (with pkgs; [
        mpv
        vlc
        kid3
        ffmpeg
      ])
      ++ [stable-pkgs.audacity];

    services.mpris-proxy.enable = cfg.mpris.enable;
  };
}
