{ config, pkgs, ... }:

{
  users.defaultUserShell = pkgs.bash;

  environment.shells = with pkgs; [ fish zsh bash ];

  # Enable shells
  programs.fish.enable = true;
  programs.zsh.enable = true;
}
