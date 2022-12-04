with import <nixpkgs>{};

let
  inherit (pkgs) callPackage fetchFromGitLab;
in
callPackage ../builder.nix rec {
  pname = "double-display";
  version = "v1.0.1";

  src = fetchFromGitLab {
    repo = "double-display";
    owner = "zhaith-izaliel-group/configuration/nixos/nixos-scripts";
    rev = version;
    sha256 = "sha256-ejEVGdoeRYxD7ahGAAncGoNQBw5cmeWG7kBzaOc05yc=";
  };

  buildInputs = [
    bash
  ];

  paths = [
    xorg.xrandr
  ];
}
