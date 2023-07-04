{ config, pkgs, ... }:

{
  home.packages = with pkgs.gnomeExtensions; [
    appindicator
    espresso
    clipboard-indicator
    color-picker
    customize-ibus
    just-perfection
    places-status-indicator
    workspace-indicator
  ];
}

