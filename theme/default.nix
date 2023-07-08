{ pkgs }:

{
  gtk-theme = import ./gtk-theme.nix { inherit pkgs; };
}

