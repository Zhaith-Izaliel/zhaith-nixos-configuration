{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    onlyoffice-bin
    evince
    qalculate-gtk
    calibre
    geogebra6
    apostrophe
    pandoc
    obs-studio
  ];
}