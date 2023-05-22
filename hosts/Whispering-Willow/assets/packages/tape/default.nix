{ pkgs }:

let
  name = "tape";
  version = "1.4.0";
  src = builtins.fetchGit {
    url = "git@gitlab.com:Zhaith-Izaliel/unfree-packages.git";
    ref = "master";
    rev = "9746945bcf8fdc8a372bd5bba6656f09373240d7";
  } + "/tape_${version}.AppImage";
  appimageContents = pkgs.appimageTools.extractType2 { inherit name src; };
in
pkgs.appimageTools.wrapType2 {
  inherit name src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/${name}.desktop \
      $out/share/applications/${name}.desktop
    sed -i "s/.*Exec.*/Exec=${name}/" \
      $out/share/applications/${name}.desktop
  '';
}

