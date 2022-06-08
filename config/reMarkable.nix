{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    rmfuse
    restream
  ];
}