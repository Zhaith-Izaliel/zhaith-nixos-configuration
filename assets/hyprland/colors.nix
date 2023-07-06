{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  name = "catppucin-hyprland";
  version = "1.2";

  src = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "hyprland";
    rev  = "v${version}";
    sha256 = "";
  };

  installPhase = ''
  mkdir -p $out
  cp -r themes $out
  '';
}

