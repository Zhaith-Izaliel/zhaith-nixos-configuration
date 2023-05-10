{ config, pkgs, ... }:

{
  users.defaultUserShell = pkgs.fish;

  environment.shells = with pkgs; [ fish ];

  # Enable zsh
  programs.fish.enable = true;
}
