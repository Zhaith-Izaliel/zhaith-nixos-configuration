{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    #(import ../assets/packages/rmfuse/default.nix)
    rmfuse
    restream
  ];
}