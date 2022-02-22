with import <nixpkgs>{};

let
  inherit (pkgs) callPackage fetchFromGitLab;
in
callPackage ../builder.nix rec {
  pname = "double-display";
  version = "v1.0.0";

  src = fetchFromGitLab {
    repo = "double-display";
    owner = "zhaith-izaliel-group/configuration/nixos/nixos-scripts";
    rev = version;
    sha256 = "0xd4nv5bh5n5xzg3fz72h4jvkai083i2yxak056azjis5blxamc9";
  };

  buildInputs = [
    bash
  ];

  paths = [
    xorg.xrandr
  ];
}
