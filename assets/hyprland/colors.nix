{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  name = "catppucin-hyprland";
  version = "1.2";

  src = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "hyprland";
    rev  = "v${version}";
    sha256 = "sha256-07B5QmQmsUKYf38oWU3+2C6KO4JvinuTwmW1Pfk8CT8=";
  };

  installPhase = ''
  mkdir -p $out
  cp -r themes $out
  '';
}

