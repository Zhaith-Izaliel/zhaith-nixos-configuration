{ inputs }:


let
  lib = inputs.nixpkgs.lib;
  makeSystem = import ./make-system.nix { inherit inputs; };
  helpers = import ./helpers.nix { inherit lib; };
in
makeSystem // helpers

