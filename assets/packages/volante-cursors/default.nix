with import <nixpkgs>{};

stdenv.mkDerivation rec {
  pname = "volante-cursors";
  version = "d1d290f";

  src = fetchFromGitHub {
    owner = "varlesh";
    repo = "volantes-cursors";
    rev = version;
    sha256 = "1nhga1h0gn8azalsmgja2sz1v1k6kkj4ivxpc0kxv8z8x7yhvcwa";
  };

  nativeBuildInputs = [
    cmake
    git
    inkscape
    xorg.xcursorgen
  ];

  buildInputs = [
    inkscape
    xorg.xcursorgen
  ];

  buildPhase = ''
    bash build.sh
  '';

  installPhase = ''
    mkdir -p $out/share/icons
	  cp -R ./dist/* $out/share/icons
  '';


  dontUseCmakeConfigure = true;
}

