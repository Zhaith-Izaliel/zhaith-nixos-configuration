with import <nixpkgs>{};

let
  inherit (pkgs) callPackage fetchFromGitLab;
in
callPackage ../builder.nix rec {
  pname = "config-share";
  version = "v3.1.0";

  src = fetchFromGitLab {
    repo = "vscode-config";
    owner = "zhaith-izaliel-group";
    rev = version;
    sha256 = "18LNK4HbD+Ib8oHvZDYs0pRyZbTop9zYzBEVKFIkd9g=";
  };

  buildInputs = [
    bash
  ];

  paths = [
    jq
  ];
}
