{
  stdenv,
  system-options-doc,
}:
stdenv.mkDerivation {
  src = ./.;
  name = "docs";

  buildPhase = ''
    mkdir -p $out
    touch "$out/system-options.md"
    cat ${system-options-doc.optionsCommonMark} >> "$out/system-options.md"
  '';

  # symlink our generated docs into the correct folder before generating
  installPhase = ''
    if [ -d "docs" ]; then
      rm -r "docs"
    fi
    mkdir "docs"

    ln -s $out "./docs"
  '';
}
