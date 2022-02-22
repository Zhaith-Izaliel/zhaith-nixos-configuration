with import <nixpkgs>{};

let
  inherit (pkgs) callPackage fetchFromGitLab;
in
callPackage ../builder.nix rec {
  pname = "nix-npm-install";
  version = "v1.0.0";

  src = fetchFromGitLab {
    repo = "nix-npm-install";
    owner = "zhaith-izaliel-group/configuration/nixos/nixos-scripts";
    rev = version;
    sha256 = "11c9a990z1y4d9ka1gh1y60d30crjm2l11gr9l10jkji92cy845l";
  };

  buildInputs = [
    bash
    nodejs
  ];

  paths = [
    nodePackages.node2nix
  ];
}
