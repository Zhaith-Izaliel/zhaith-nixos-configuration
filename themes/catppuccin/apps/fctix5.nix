{ pkgs, inputs }:

{
  package = pkgs.stdenv.mkDerivation rec {
    pname = "catppuccin-fcitx5";
    version = "ce244cf";
    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "fcitx5";
      rev = version;
      sha256 = "sha256-uFaCbyrEjv4oiKUzLVFzw+UY54/h7wh2cntqeyYwGps=";
    };

    installPhase = ''
    local themeDir=$out/share/fcitx5/themes
    mkdir -p $themeDir
    cp -aR ./src/* $themeDir
    '';
  };
  name = "catppuccin-macchiato";
}

