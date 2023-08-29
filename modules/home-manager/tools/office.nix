{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.tools.office;
in
{
  options.hellebore.tools.office = {
    enable = mkEnableOption "Hellebore office tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      onlyoffice-bin
      evince
      qalculate-gtk
      calibre
      obsidian
      gnome.simples-scan
    ];
  };
}

