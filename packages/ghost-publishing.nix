{
  stdenv,
  ghost-cli,
}:
stdenv.mkDerivation {
  version = "5.87.1";
  pname = "ghost-publishing";

  buildInputs = [
    ghost-cli
  ];

  buildPhase = ''
    mkdir -p "$out"
  '';

  installPhase = ''
    ghost install "$version" --db=sqlite3 --no-enable --no-prompt --no-stack --no-setup --no-start --dir "$out"
  '';
}
