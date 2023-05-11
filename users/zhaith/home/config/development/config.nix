{ pkgs, lib }:

let
  config = pkgs.stdenv.mkDerivation rec {
    name = "neovim-config";
    version = "1.0.0";

    src = pkgs.fetchFromGitLab {
      repo = name;
      owner = "zhaith-izaliel-group/configuration";
      rev = "v${version}";
      sha256 = "sha256-qbhhLjWnoLWkrh6iimgPQOAUmT1TYnmof2b+DOdqWVE=";
    };

    installPhase = ''
    mkdir -p $out
    cp -r --target-directory $out lua init.lua
    '';
  };
in
{
  init = builtins.readFile "${config}/init.lua";

  lua = lib.sources.cleanSource "${config}/lua";
}
