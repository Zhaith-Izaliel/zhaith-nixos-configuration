{stdenv, pname, version, src, nativeBuildInputs ? [], buildInputs ? [] }:

stdenv.mkDerivation rec {
  inherit pname version src nativeBuildInputs buildInputs;

  dontUseCmakeBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp ${pname}.sh $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';

  dontUseCmakeConfigure = true;
}