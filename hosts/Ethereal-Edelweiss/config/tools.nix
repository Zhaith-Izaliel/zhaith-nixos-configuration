{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    htop
    jq
    neofetch
    zip
    gnumake
    unzip
    pstree
    wget
    curl
    tree
    vim
    ranger
    git
    direnv
    viu
  ];
}
