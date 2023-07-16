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
  ];

  programs.nix-ld.enable = true;

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
      thunar-media-tags-plugin
    ];
  };

  nixpkgs.config.permittedInsecurePackages = [
    "nodejs-14.21.3"
  ];
}

