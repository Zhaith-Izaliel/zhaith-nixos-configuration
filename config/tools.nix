{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    htop
    jq
    neofetch
    zip
    unzip
    pstree
    pciutils
    gparted
    wget
    qview
    curl
    tree
    xbrightness
    mcrcon
    sublime
    torrential
    gthumb
    etcher
    rar
    unrar
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-14.2.9" # HACK For Etcher
  ];
}