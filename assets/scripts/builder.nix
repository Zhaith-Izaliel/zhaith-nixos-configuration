{stdenv, lib, pname, version, src, makeWrapper, buildInputs ? [], paths ? [], desktopItemPhase ? "" }:

let
  wrapperPath = with lib; makeBinPath (paths);
  desktopItemPhaseName = if (desktopItemPhase != "") then "desktopItemPhase" else "";
in
stdenv.mkDerivation rec {
  inherit pname version src buildInputs desktopItemPhase;

  nativeBuildInputs = [
    makeWrapper
  ];

  postPhases = [
    desktopItemPhaseName
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp ${pname}.sh $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';

  postFixup = ''
    # Ensure all dependencies are in PATH
      wrapProgram $out/bin/${pname} \
        --prefix PATH : "${wrapperPath}"
  '';

  dontUseCmakeBuild = true;
  dontUseCmakeConfigure = true;

  meta.mainProgram = pname;
}

