{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    discord-ptb
  ];
}