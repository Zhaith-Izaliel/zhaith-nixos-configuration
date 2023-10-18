{ pkgs }:

let
  inherit (pkgs) stdenv mkdocs python310Packages;
  options-doc = pkgs.callPackage ./modules/docs.nix {};
in
stdenv.mkDerivation {
  src = ./.;
  name = "docs";

  # depend on our options doc derivation
  buildInput = [options-doc];

  # mkdocs dependencies
  nativeBuildInputs = [
    mkdocs
    python310Packages.mkdocs-material
    python310Packages.pygments
  ];

  # symlink our generated docs into the correct folder before generating
  buildPhase = ''
    ln -s ${options-doc} "./docs/nixos-options.md"
    # generate the site
    mkdocs build
  '';

  # copy the resulting output to the derivation's $out directory
  installPhase = ''
    mv site $out
  '';
}

