{ pkgs, ... }:

{
  home.packages = with pkgs; [
    inkscape
    gimp
    gimpPlugins.gmic
  ];
}

