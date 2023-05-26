{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    inkscape
    gimp
    gimpPlugins.gmic
  ];
}

