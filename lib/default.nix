{ inputs }:

let
  makeSystem = import ./make-system { inherit inputs; };
in
  makeSystem

