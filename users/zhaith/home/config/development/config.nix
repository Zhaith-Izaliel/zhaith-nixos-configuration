{ pkgs, lib }:

let
  config = pkgs.stdenv.mkDerivation rec {
    name = "neovim-config";
    version = "1.3.0";

    src = pkgs.fetchFromGitLab {
      repo = name;
      owner = "Zhaith-Izaliel";
      rev = "v${version}";
      sha256 = "sha256-SJ/p3vmGtuMwt4h/2ekjJIYdh05lM/7xNjZyLahfEIg";
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

