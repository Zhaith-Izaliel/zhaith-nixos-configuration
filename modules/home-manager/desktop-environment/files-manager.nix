{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.desktop-environment.files-manager;
in
{
  options.hellebore.desktop-environment.files-manager = {
    enable = mkEnableOption "Hellebore files manager's configuration";

    supports = {
      images = mkEnableOption "Hellebore files manager's images support";

      archives = mkEnableOption "Hellebore files manager's archives support";

      torrents = mkEnableOption "Hellebore files manager's torrents support";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      cinnamon.nemo
    ] ++ lists.optionals cfg.supports.images (with pkgs; [
      qview
      gthumb
    ]) ++ lists.optionals cfg.supports.archives (with pkgs; [
      cinnamon.nemo-fileroller
      gnome.file-roller
      zip
      unzip
    ]) ++ lists.optionals cfg.supports.torrents (with pkgs; [
      fragments
    ]);
  };
}

