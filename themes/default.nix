{
  pkgs,
  lib,
  inputs,
}: {
  catppuccin = import ./catppuccin {inherit pkgs lib inputs;};
}
