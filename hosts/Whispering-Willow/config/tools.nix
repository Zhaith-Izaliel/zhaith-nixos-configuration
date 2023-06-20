{ config, pkgs, unstable-pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gotop
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
    erdtree
    nix-alien
    viu
    (import ../assets/packages/tape { inherit pkgs; })
  ];

  programs.nix-ld.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
    "nodejs-14.21.3"
  ];
}

