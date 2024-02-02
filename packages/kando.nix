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
    sha256 = "";
  };

  npmDepsHash = "";

  buildInputs = [
    cmake
    xorg.libX11
    xorg.libXtst
    wayland
    libxkbcommon
  ];
}
