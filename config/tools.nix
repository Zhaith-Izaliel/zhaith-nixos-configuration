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
    torrential
    gthumb
    rar
    unrar
    teamviewer
    cheat
  ];

  services.teamviewer.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
    "electron-14.2.9" # HACK For Etcher
  ];
}