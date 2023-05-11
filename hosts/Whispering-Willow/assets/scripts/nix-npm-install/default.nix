{
  fetchFromGitLab,
  callPackage,
  bash,
  nodejs,
  node2nix,
}:

callPackage ../builder.nix rec {
  pname = "nix-npm-install";
  version = "v1.0.2";

  src = fetchFromGitLab {
    repo = "nix-npm-install";
    owner = "zhaith-izaliel-group/configuration/nixos/nixos-scripts";
    rev = version;
    sha256 = "sha256-RG2WGe6MKCvIy4hL0QqI1iCHTmrnwZFbGeCQP5Toelk=";
  };

  buildInputs = [
    bash
    nodejs
  ];

  paths = [
    node2nix
  ];
}
