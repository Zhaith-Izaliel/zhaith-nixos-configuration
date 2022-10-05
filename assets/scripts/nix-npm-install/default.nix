with import <nixpkgs>{};

let
  inherit (pkgs) callPackage fetchFromGitLab;
in
callPackage ../builder.nix rec {
  pname = "nix-npm-install";
  version = "v1.0.1";

  src = fetchFromGitLab {
    repo = "nix-npm-install";
    owner = "zhaith-izaliel-group/configuration/nixos/nixos-scripts";
    rev = version;
    sha256 = "sha256-A+ghVVQLMRa/jMa2jC0++eCjlgvxpGSccdBS1NziPc8=";
  };

  buildInputs = [
    bash
    nodejs
  ];

  paths = [
    nodePackages.node2nix
  ];
}
