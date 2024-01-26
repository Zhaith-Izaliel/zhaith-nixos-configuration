{
  src,
  buildNpmPackage,
  cmake,
  mpv,
  boost,
  libtorrent-rasterbar,
  electron,
}:

buildNpmPackage rec {
  inherit src;
  pname = "KawAnime";
  version = src.shortRev;

  npmDepsHash = "sha256-4B2ZbL2BWVM8RVoQELI0IooS5ikTjMwD3E8dPyvGiMg=";

  installPhase = ''
    runHook preInstall

    npm install
    mkdir -p $out/{bin,share/KawAnime}
    cp -r node_modules $out/share/KawAnime/
    install -m 444 -D dist/linux-unpacked $out/bin/KawAnime
    makeWrapper ${electron}/bin/electron $out/bin/KawAnime --add-flags $out/share/element/electron

    runHook postInstall
  '';

  distPhase = ''
    npm run dist:linux
  '';

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    mpv
    boost
    libtorrent-rasterbar
  ];
}

