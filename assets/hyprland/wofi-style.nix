{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  name = "catppucin-wofi";
  version = "e21f47a";

  src = pkgs.fetchFromGitHub {
    owner = "laymoth";
    repo = "wofi";
    rev  = version;
    sha256 = "";
  };

  installPhase = ''
  mkdir -p $out
  cp -r src $out
  '';
}

