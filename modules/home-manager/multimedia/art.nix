{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.art;
in
{
  options.hellebore.art = {
    enable = mkEnableOption "art related packages";

    gmic.enable = mkEnableOption "gmic plugins";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      inkscape
      gimp
      krita
      drawio
    ] ++ (if cfg.gmic.enable then
    with pkgs; [
      gmic
      gmic-qt
      gimpPlugins.gmic
    ]
    else []);
  };
}

