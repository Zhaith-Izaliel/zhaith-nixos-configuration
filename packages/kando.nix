{
  buildNpmPackage,
  fetchFromGitHub,
  cmake,
  xorg,
  wayland,
  libxkbcommon,
}:
buildNpmPackage rec {
  pname = "kando";
  version = "0.5.0";
  src = fetchFromGitHub {
    owner = "kando-menu";
    repo = "kando";
    rev = "v${version}";
    sha256 = "sha256-Aj8YfkjYx5MJ2F7WskeGS6crWdD+L0tAkzViR6tlDio=";
  };

  npmDepsHash = "sha256-/IfNVQJzVD/UBKyWa5drO0h8ckegZDMpEhLeXcNgrdw=";

  buildInputs = [
    cmake
    xorg.libX11
    xorg.libXtst
    wayland
    libxkbcommon
  ];

  buildPhase = ''
    npm install
    npm run package
  '';

  makeCacheWritable = true;

  npmFlags = ["--legacy-peer-deps"];

  installPhase = ''
    runhook preInstall
    install -m 444 out/kando $out/bin/kando
    runhook postInstall
  '';
}
