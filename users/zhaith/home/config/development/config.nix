{ pkgs, lib }:

let
  config = pkgs.stdenv.mkDerivation rec {
    name = "neovim-config";
    version = "1.4.0";

    src = pkgs.fetchFromGitLab {
      repo = name;
      owner = "Zhaith-Izaliel";
      rev = "v${version}";
      sha256 = "sha256-FqJyGzk353elQE9PfzNR1PIdzIIUFFIz4eb7hcIBbgg=";
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

