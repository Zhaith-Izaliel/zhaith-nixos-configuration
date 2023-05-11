{ pkgs, theme ? "tela", icon ? "color", screen ? "1080p" }:

{
  package = pkgs.stdenv.mkDerivation rec {
    name = "grub2-themes";
    version = "2022-10-30";

    src = pkgs.fetchFromGitHub {
      owner = "vinceliuice";
      repo = name;
      rev  = version;
      sha256 = "";
    };

    installPhase = ''
    mkdir -p $out/${theme}
    ./install.sh -t ${theme} -i ${icon} -s ${screen} -g $out/${theme}
    '';
  };
}
