{ src, buildNpmPackage, cmake, mpv, boost, libtorrent-rasterbar }:

buildNpmPackage rec {
  inherit src;
  pname = "KawAnime";
  version = src.shortRev;

  npmDepsHash = "sha256-4B2ZbL2BWVM8RVoQELI0IooS5ikTjMwD3E8dPyvGiMg=";

  nativeBuildInputs = [
    cmake
  ];

  buildPhase = ''
    npm run dist:linux
  '';

  buildInputs = [
    mpv
    boost
    libtorrent-rasterbar
  ];

  installPhase = ''
    install -Dt $out/bin/KawAnime dist/linux-unpacked
  '';

}

