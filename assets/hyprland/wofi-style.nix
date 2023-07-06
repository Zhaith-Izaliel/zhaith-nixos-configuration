{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  name = "catppucin-wofi";
  version = "e21f47a";

  src = pkgs.fetchFromGitHub {
    owner = "laymoth";
    repo = "wofi";
    rev  = version;
    sha256 = "sha256-A34ccUNBxlPevFd1W78vCBOYQ2NyuunImkvt/4HtObs=";
  };

  installPhase = ''
  mkdir -p $out
  cp -r src $out
  '';
}

