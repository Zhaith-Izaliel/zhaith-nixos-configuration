{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf optional optionals;
  cfg = config.hellebore.desktop-environment.files-manager;
in {
  options.hellebore.desktop-environment.files-manager = {
    enable = mkEnableOption "Hellebore files manager's configuration";

    supports = {
      images = mkEnableOption "Hellebore files manager's images support";

      archives = mkEnableOption "Hellebore files manager's archives support";

      torrents = mkEnableOption "Hellebore files manager's torrents support";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        nemo
      ]
      ++ optionals cfg.supports.images [
        qview
      ]
      ++ optionals cfg.supports.archives [
        zip
        unzip
        nemo-fileroller
        file-roller
      ]
      ++ optional cfg.supports.torrents fragments;
  };
}
