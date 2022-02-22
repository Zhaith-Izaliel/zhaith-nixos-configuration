with import <nixpkgs>{};

let
  inherit (pkgs) callPackage fetchFromGitLab;
  my-build-inputs = [
    scream
    virt-manager
    pstree
    libnotify
    bash
    (import ../../packages/looking-glass/default.nix)
  ];
in
callPackage ../builder.nix rec {
  pname = "start-vm";

  version = "v1.0.0";

  src = fetchFromGitLab {
    repo = "start-vm";
    owner = "zhaith-izaliel-group/configuration/nixos/nixos-scripts";
    rev = version;
    sha256 = "1pgv5wgpxl2l8fmc39nx8sfc07nwl8mp01fh46w3yd1bpzd4b05j";
  };

  buildInputs = [
    bash
  ];

  paths = [
    scream
    virt-manager
    pstree
    libnotify
    (import ../../packages/looking-glass/default.nix)
  ];
}
