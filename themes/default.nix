{
  pkgs,
  lib,
  inputs,
}: {
  catppuccin-macchiato = import ./catppuccin-macchiato {inherit pkgs lib inputs;};
}
