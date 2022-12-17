with import <nixpkgs>{};

let
  inherit (pkgs) callPackage fetchFromGitLab;
in
callPackage ../builder.nix rec {
  pname = "power-management";

  version = "v2.0.0";

  src = fetchFromGitLab {
    repo = "power-management";
    owner = "zhaith-izaliel-group/configuration/nixos/nixos-scripts";
    rev = version;
    sha256 = "sha256-ostsfd5HdamcoD7aQx9YGMoBIVkHYAoyJtTHeg1cQMs=";
  };

  buildInputs = [
    bash
  ];

  paths = [
    libnotify
  ];
}
