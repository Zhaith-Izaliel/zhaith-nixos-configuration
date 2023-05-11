{ pkgs, lib }:

{
  vim-kitty-navigator = pkgs.stdenv.mkDerivation {
    name = "vim-kitty-navigator-kitten";

    src = pkgs.fetchFromGitHub {
      owner = "knubie";
      repo = "vim-kitty-navigator";
      rev  = "949ab61";
      sha256 = "sha256-AjN1vbuixmtyPQ4CkVhH776FjicPfVBn9TPc8QdFJKc=";
    };

    installPhase = ''
      mkdir -p $out
      cp -r *.py $out
    '';
  };
}
