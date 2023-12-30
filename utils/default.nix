{ inputs }:

let
  inherit (inputs.nixpkgs) lib;
  makeSystem = import ./make-system.nix { inherit inputs; };
  makeWaybar = import ./make-waybar.nix { inherit lib; };
in
makeWaybar // makeSystem

