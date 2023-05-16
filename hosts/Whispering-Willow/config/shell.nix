{ config, pkgs, ... }:

{
  environment.shells = with pkgs; [ fish zsh bash bashInteractive ];

  # Enable shells
  programs.fish.enable = true;
  programs.zsh.enable = true;
}
