{ config, pkgs, ... }:

{
  imports = [
    ./graphics.nix
    ./kernel.nix
    ./vm.nix
  ];
}