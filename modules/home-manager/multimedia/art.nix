{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf optionals;
  cfg = config.hellebore.multimedia.art;
in {
  options.hellebore.multimedia.art = {
    enable = mkEnableOption "art related packages";

    gmic.enable = mkEnableOption "gmic plugins";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        inkscape
        gimp
        krita
        drawio
      ]
      ++ optionals cfg.gmic.enable
      [
        gmic
        gmic-qt
        gimpPlugins.gmic
      ];
  };
}
