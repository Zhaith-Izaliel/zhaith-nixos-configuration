{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    vscode
    git
    gitAndTools.gitflow
    gitAndTools.git-ignore
    gnumake
    cmake
    vim
    direnv
    shfmt
    onefetch
    docker-compose
    glab
  ];
}