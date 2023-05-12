{ config, pkgs, unstable-pkgs, ... }:

{
  environment.systemPackages = [
    (import ./double-display { inherit pkgs; })
    (import ./nix-npm-install { inherit pkgs; })
    (import ./start-vm { inherit pkgs unstable-pkgs; })
    (import ./power-management { inherit pkgs; })
  ];
}