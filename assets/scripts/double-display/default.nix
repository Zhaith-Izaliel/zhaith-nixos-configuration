with import <nixpkgs>{};

let
  inherit (pkgs) callPackage fetchFromGitLab;
in
callPackage ../builder.nix rec {
  pname = "double-display";
  version = "v1.0.0";
  nativeBuildInputs = [
    bash
    xorg.xrandr
  ];
  src = fetchFromGitLab {
    repo = "double-display";
    owner = "zhaith-izaliel-group/configuration/nixos/nixos-scripts";
    rev = version;
    sha256 = "18LNK4HbD+Ib8oHvZDYs0pRyZbTop9zYzBEVKFIkd9g=";
  };
}
