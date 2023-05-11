with import <nixpkgs>{};

let
  inherit (pkgs) callPackage fetchFromGitLab;
in
callPackage ../builder.nix rec {
  pname = "double-display";
  version = "v1.0.2";

  src = fetchFromGitLab {
    repo = "double-display";
    owner = "zhaith-izaliel-group/configuration/nixos/nixos-scripts";
    rev = version;
    sha256 = "sha256-AZPGAUpm9Pr/RwnQBD0epN8M9fkVE1OsMf/FDdCAI6E=";
  };

  buildInputs = [
    bash
  ];

  paths = [
    xorg.xrandr
  ];
}
