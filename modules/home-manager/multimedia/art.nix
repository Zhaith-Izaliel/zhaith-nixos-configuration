{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
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
      ++ (
        if cfg.gmic.enable
        then
          with pkgs; [
            gmic
            gmic-qt
            gimpPlugins.gmic
          ]
        else []
      );
  };
}
