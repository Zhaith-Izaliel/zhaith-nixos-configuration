{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    rmapi
    restream
  ];
}