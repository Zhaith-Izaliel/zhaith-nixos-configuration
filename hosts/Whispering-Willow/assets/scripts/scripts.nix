{ config, pkgs, ... }:

{
  environment.systemPackages = [
    (import ./double-display/default.nix)
    (import ./nix-npm-install/default.nix)
    (import ./start-vm/default.nix)
    (import ./power-management/default.nix)
  ];
}
