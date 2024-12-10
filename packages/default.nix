{
  pkgs,
  inputs,
}: let
  nodejs-packages = import ./nodejs {
    inherit pkgs;
    inherit (pkgs) stdenv;
    nodejs = pkgs.nodejs;
  };
in rec {
  fusion = pkgs.callPackage ./fusion.nix {};
  # elasticdump = nodejs-packages.elasticdump.overrideAttrs (
  #   final: prev: {
  #     buildInputs =
  #       [
  #         nodejs-packages.JSONStream
  #         nodejs-packages.request
  #       ]
  #       ++ prev.buildInputs;

  #     installPhase =
  #       prev.installPhase
  #       + ''

  #         mkdir -p $out/node_modules
  #         ln -s ${nodejs-packages.JSONStream}/lib/node_modules/* $out/node_modules
  #         ln -s ${nodejs-packages.request}/lib/node_modules/* $out/node_modules
  #       '';
  #   }
  # );
}
