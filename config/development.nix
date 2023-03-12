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
    # Unity
    unityhub
    mono
    dotnet-sdk

    mongodb-tools #TEMP For FV
  ];

  services.mongodb.enable = true; #TEMP For FV
}