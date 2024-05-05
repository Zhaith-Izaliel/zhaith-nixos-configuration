{
  appimageTools,
  fetchurl,
}: let
  name = "modrinth";

  version = "0.7.1";

  src = fetchurl {
    url = "https://launcher-files.modrinth.com/versions/${version}/linux/modrinth-app_${version}_amd64.AppImage";
    sha256 = "sha256-JPalOzTuyJ2fhlHaq4cdW+D+JhbajRY2CXKMLBkGwMU=";
    name = "modrinth.AppImage";
  };
  appimageContents = appimageTools.extractType1 {inherit name src;};
in
  appimageTools.wrapType1 {
    inherit name src version;

    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/modrinth-app.desktop $out/share/applications/${name}.desktop
      sed -i 's/.*Exec.*/Exec=${name}/' $out/share/applications/${name}.desktop
      cp -r ${appimageContents}/usr/share/icons $out/share
    '';
  }
