{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (import ./double-display/default.nix)
    (import ./nix-npm-install/default.nix)
    (import ./start-vm/default.nix)
    (import ./config-share/default.nix)
  ];
}