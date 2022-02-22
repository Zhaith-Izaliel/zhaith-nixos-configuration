{stdenv, lib, pname, version, src, makeWrapper, buildInputs ? [], paths ? [] }:

stdenv.mkDerivation rec {
  inherit pname version src buildInputs;

  nativeBuildInputs = [
    makeWrapper
  ];

  wrapperPath = with lib; makeBinPath (paths);

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
}