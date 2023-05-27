{ pkgs, lib }:

let
  config = pkgs.stdenv.mkDerivation rec {
    name = "neovim-config";
    version = "1.2.0";

    src = pkgs.fetchFromGitLab {
      repo = name;
      owner = "Zhaith-Izaliel";
      rev = "v${version}";
      sha256 = "sha256-XFjhxtXxP2SQp8SWt4d9ocb+EXT2taq2mINOWEK5dIo=";
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

