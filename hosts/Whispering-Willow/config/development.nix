{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  documentation.dev.enable = true;
  services.lorri.enable = true;

  environment.systemPackages = with pkgs; [
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
    universal-ctags
    # Man
    man-pages
    man-pages-posix
    # Unity
    unityhub
    mono
    dotnet-sdk

    # mongodb-tools # TEMP: For FV
  ];

  # services.mongodb.enable = true; # TEMP: For FV
}

