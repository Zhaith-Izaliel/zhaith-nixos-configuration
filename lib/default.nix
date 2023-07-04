{ inputs }:

let
  makeSystem = import ./make-system.nix { inherit inputs; };
in
  makeSystem

