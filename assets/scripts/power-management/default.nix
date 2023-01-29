with import <nixpkgs>{};

let
  inherit (pkgs) callPackage fetchFromGitLab;
in
callPackage ../builder.nix rec {
  pname = "power-management";

  version = "v2.1.1";

  src = fetchFromGitLab {
    repo = "power-management";
    owner = "zhaith-izaliel-group/configuration/nixos/nixos-scripts";
    rev = version;
    sha256 = "sha256-zrThij/dWZA2lGIW1PJpGgjQswydKwgGAS0Y9EHzJ3Q=";
  };

  buildInputs = [
    bash
  ];

  paths = [
    libnotify
  ];
}
