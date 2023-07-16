{ pkgs }:

pkgs.callPackage ../builder.nix rec {
  pname = "nix-npm-install";
  version = "v1.0.2";

  src = pkgs.fetchFromGitLab {
    repo = pname;
    owner = "Zhaith-Izaliel";
    rev = version;
    sha256 = "sha256-RG2WGe6MKCvIy4hL0QqI1iCHTmrnwZFbGeCQP5Toelk=";
  };

  buildInputs = with pkgs; [
    bash
    nodejs
  ];

  paths = with pkgs; [
    nodePackages.node2nix
  ];
}

