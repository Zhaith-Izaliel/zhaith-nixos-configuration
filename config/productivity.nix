{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    evolution
    (import ../assets/packages/fluent-reader/default.nix)
  ];
}