{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    htop
    ripgrep
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
    fragments
    gthumb
    rar
    unrar
  ];

  services.teamviewer.enable = true;
}