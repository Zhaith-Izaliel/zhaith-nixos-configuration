{ pkgs, ... }:

{
  home.packages = with pkgs; [
    onlyoffice-bin
    evince
    qalculate-gtk
    calibre
    evolution
  ];
}

