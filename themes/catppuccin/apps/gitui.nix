{ pkgs, lib, inputs }:

rec {
  package = pkgs.stdenv.mkDerivation rec {
    pname = "gitui-catppuccin";
    version  = "3997836";

    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "gitui"; # Bat uses sublime syntax for its themes
      rev = version;
      sha256 = "sha256-kWaHQ1+uoasT8zXxOxkur+QgZu1wLsOOrP/TL+6cfII=";
    };

    installPhase = ''
    mkdir -p $out
    cp -r theme $out
    '';
  };
  file = "${package}/theme/macchiato.ron";
}

