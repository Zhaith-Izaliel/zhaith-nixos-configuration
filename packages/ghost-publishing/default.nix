{
  stdenv,
  nodejs,
  yarn,
  vips,
  ghost-cli,
}:
stdenv.mkDerivation {
  version = "5.87.1";
  pname = "ghost-publishing";

  nativeBuildInputs = [
    ghost-cli
  ];

  buildInputs = [
    nodejs
    yarn
    vips
  ];
  builder = ./builder.sh;
}
