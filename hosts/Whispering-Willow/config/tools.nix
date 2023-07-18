{ pkgs, ... }:

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
    wget
    curl
    tree
    rar
    unrar
    erdtree
    nix-alien
    tape
  ];

  programs.nix-ld.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
    "nodejs-14.21.3"
  ];
}

