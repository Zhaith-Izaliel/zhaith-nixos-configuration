{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    onlyoffice-bin
    evince
    qalculate-gtk
    calibre
    pandoc
    evolution
  ];
}

