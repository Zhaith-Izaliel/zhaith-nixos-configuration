{
  pkgs,
  lib,
  inputs,
  extra-utils,
}: {
  catppuccin-macchiato = import ./catppuccin-macchiato {inherit pkgs lib inputs extra-utils;};
}
