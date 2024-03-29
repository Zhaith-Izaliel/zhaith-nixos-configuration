{
  appimageTools,
  fetchurl,
}: let
  name = "affine";

  version = "0.13.3";

  src = fetchurl {
    url = "https://github.com/toeverything/AFFiNE/releases/download/v${version}/affine-${version}-stable-linux-x64.appimage";
    sha256 = "1i1gyy4ld1l57378scs2i068m2s8sakqw7kc8548inbl2vz1y0pf"; # Change for the sha256 you get after running nix-prefetch-url https://github.com/toeverything/AFFiNE/releases/download/v0.13.3/affine-0.13.3-stable-linux-x64.appimage
    name = "affine.AppImage";
  };
  appimageContents = appimageTools.extractType2 {inherit name src;};
in
  appimageTools.wrapType2 {
    inherit name src version;

    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/AFFiNE.desktop $out/share/applications/AFFiNE.desktop
      sed -i 's/.*Exec.*/Exec=affine/' $out/share/applications/AFFiNE.desktop
      cp -r ${appimageContents}/usr/share/icons $out/share
    '';
  }
