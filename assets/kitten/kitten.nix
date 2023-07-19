{ pkgs, lib }:

{
  smart-splits-nvim-kitten = pkgs.stdenv.mkDerivation rec {
    name = "smart-splits-nvim-kitten";
    version =  "7aad601";

    src = pkgs.fetchFromGitHub {
      owner = "mrjones2014";
      repo = "smart-splits.nvim";
      rev  = version;
      sha256 = "";
    };

    installPhase = ''
      mkdir -p $out
      cp -r kitty/*.py $out
    '';
  };
}

