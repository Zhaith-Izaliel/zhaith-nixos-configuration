{
  appimageTools,
  fetchurl,
}: let
  name = "affine";

  version = "0.13.1";

  src = fetchurl {
    url = "https://github.com/toeverything/AFFiNE/releases/download/v${version}/affine-${version}-stable-linux-x64.appimage";
    sha256 = "sha256-AhzzOKa71sHkjdTqxI23MGYoYU14JPwlbZ9kn3wT5SI"; # Change for the sha256 you get after running nix-prefetch-url https://download.ankama.com/launcher/full/linux/x64
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
