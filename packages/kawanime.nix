{ src, buildNpmPackage, cmake, mpv, boost }:

buildNpmPackage rec {
  inherit src;
  pname = "KawAnime";
  version = src.shortRev;

  npmDepsHash = "";

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    mpv
    boost
  ];

  # The prepack script runs the build script, which we'd rather do in the build phase.
  npmPackFlags = [ "--ignore-scripts" ];
}

