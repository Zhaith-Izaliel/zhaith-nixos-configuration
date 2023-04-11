{ config, pkgs, ... }:

{
  #Set ZSH as defautl Shell
  users.defaultUserShell = pkgs.zsh;

  environment.shells = with pkgs; [ zsh ];

  # Enable zsh
  programs.zsh.enable = true;
}