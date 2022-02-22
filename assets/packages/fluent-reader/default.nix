with import <nixpkgs>{};

let
  name = "fluent-reader";
  version = "1.0.2";
  src = fetchurl {
    url = "https://github.com/yang991178/fluent-reader/releases/download/v${version}/Fluent.Reader.${version}.AppImage";
    sha256 = "0890kz1ry0bprsgamfij1mzakzg2hz394x35iqfg52g1k04l1pg1"; 
    name = "fluent-reader.AppImage";
 };

  appimageContents = appimageTools.extractType2 { inherit name src; };
in
appimageTools.wrapType2 {
  inherit name src;

  extraInstallCommands = ''
    DESKTOP_ITEM_DIR=$out/share/applications
    mkdir -p $DESKTOP_ITEM_DIR

    echo '[Desktop Entry]
    Type=Application
    Name=Fluent Reader
    Comment=A modern desktop RSS reader
    Exec=fluent-reader
    Terminal=false
    Icon=fluent-reader
    Categories=Office;Utility;
    ' > $DESKTOP_ITEM_DIR/fluent-reader.desktop
  '';
}