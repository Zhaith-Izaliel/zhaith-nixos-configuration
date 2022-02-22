{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    krita
    inkscape
    gimp
    gmic-qt-krita
    gimpPlugins.gmic
    xf86_input_wacom
    libwacom
  ];
}