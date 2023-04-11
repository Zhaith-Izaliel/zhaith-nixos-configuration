{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    inkscape
    gimp
    gimpPlugins.gmic
    krita
    gmic-qt-krita
  ];

  services.xserver.wacom.enable = true;
}