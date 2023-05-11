{ config, pkgs, ... }:

{
  users.defaultUserShell = pkgs.bash;

  services.lorri.enable = true;

  environment.shells = with pkgs; [ fish bash zsh ];

  programs.fish.enable = true;
  programs.zsh.enable = true;
}
