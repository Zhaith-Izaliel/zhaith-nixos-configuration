{
  config,
  lib,
  extra-utils,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf optional optionals;
  inherit (extra-utils.compatibility) mkCompatibilityAttrs;
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
      (mkCompatibilityAttrs rec {
        name = "nemo";
        set = pkgs;
        new = [pkgs.${name}];
        old = [pkgs.cinnamon.${name}];
      })
      ++ optionals cfg.supports.images [
        qview
      ]
      ++ optionals cfg.supports.archives (
        [
          zip
          unzip
        ]
        ++ (mkCompatibilityAttrs rec {
          name = "nemo-fileroller";
          set = pkgs;
          new = [pkgs.${name}];
          old = [pkgs.cinnamon.${name}];
        })
        ++ (mkCompatibilityAttrs rec {
          name = "file-roller";
          set = pkgs;
          new = [pkgs.${name}];
          old = [pkgs.gnome.${name}];
        })
      )
      ++ optional cfg.supports.torrents fragments;
  };
}
