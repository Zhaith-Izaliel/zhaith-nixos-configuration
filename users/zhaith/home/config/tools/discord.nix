{ pkgs, ... }:

{
  home.packages = with pkgs; [
    discord-ptb
    betterdiscordctl
  ];
}

