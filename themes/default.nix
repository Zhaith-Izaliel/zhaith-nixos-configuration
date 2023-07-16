{ pkgs, lib }:

{
  catppuccin = import ./catppuccin { inherit pkgs lib; };
}

