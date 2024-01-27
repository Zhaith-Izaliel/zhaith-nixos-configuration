{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.hellebore.multimedia.anime;
in {
  options.hellebore.multimedia.anime = {
    enable = mkEnableOption "Hellebore's Multimedia Animes support";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      KawAnime
    ];
  };
}
