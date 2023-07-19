{ pkgs, lib }:

{
  smart-splits-nvim-kitten = pkgs.stdenv.mkDerivation rec {
    name = "smart-splits-nvim-kitten";
    version =  "7aad601";

    src = pkgs.fetchFromGitHub {
      owner = "mrjones2014";
      repo = "smart-splits.nvim";
      rev  = version;
      sha256 = "sha256-mLLh8rcq5D6dA9Iwn3ULiHRG/jI4Sjct4J498C+QPO8=";
    };

    dontBuild = true;

    installPhase = ''
      mkdir -p $out
      cp -r kitty/*.py $out
    '';
  };
}

