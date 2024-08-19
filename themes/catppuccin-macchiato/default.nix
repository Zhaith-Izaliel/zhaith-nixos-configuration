{
  pkgs,
  lib,
  inputs,
  extra-utils,
}: let
  colors = import ./colors.nix {};
  apps = import ./apps {inherit pkgs lib inputs colors extra-utils;};
in
  apps // {inherit colors;}
