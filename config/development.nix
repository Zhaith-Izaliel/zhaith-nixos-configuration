{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  documentation.dev.enable = true;

  environment.systemPackages = with pkgs; [
    # Editors
    vscode
    vim
    # Git
    git
    gitAndTools.gitflow
    git-ignore
    gitkraken
    # hooks
    direnv
    # Tools
    onefetch
    docker-compose
    glab
    # Nix
    rnix-lsp
    nixpkgs-fmt
    # Bash
    shfmt
    # Man
    man-pages
    man-pages-posix

    mongodb-tools #TEMP
  ];

  services.mongodb.enable = true; #TEMP
}