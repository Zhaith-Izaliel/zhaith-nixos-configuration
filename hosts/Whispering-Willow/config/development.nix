{ pkgs, ... }:

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
    universal-ctags
    # Man
    man-pages
    man-pages-posix
  ];
}

