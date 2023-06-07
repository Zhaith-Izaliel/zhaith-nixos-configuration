{ pkgs, lib }:

let
  config = pkgs.stdenv.mkDerivation rec {
    name = "neovim-config";
    version = "1.6.0";

    src = pkgs.fetchFromGitLab {
      repo = name;
      owner = "Zhaith-Izaliel";
      rev = "v${version}";
      sha256 = "sha256-FcpfzjnSnCfIaRca6TFRUAxcckC4UDI34yrHiW/nmpY=";
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

