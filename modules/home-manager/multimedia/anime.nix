{
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
    warnings = [
      "`hellebore.multimedia.anime` is unused at the moment, you shouldn't enable it, though it does nothing"
    ];
  };
}