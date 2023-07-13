{ inputs, theme }:

let
  makeSystem = import ./make-system.nix { inherit inputs theme; };
in
  makeSystem

