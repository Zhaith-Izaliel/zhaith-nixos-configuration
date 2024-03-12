{
  pkgs,
  lib,
  inputs,
}: let
  colors = import ./colors.nix {};
  apps = import ./apps {inherit pkgs lib inputs colors;};
in
  apps // {inherit colors;}
