{ pkgs }:

pkgs.callPackage ../builder.nix rec {
  pname = "power-management";

  version = "v2.1.1";

  src = pkgs.fetchFromGitLab {
    repo = "power-management";
    owner = "zhaith-izaliel-group/configuration/nixos/nixos-scripts";
    rev = version;
    sha256 = "sha256-zrThij/dWZA2lGIW1PJpGgjQswydKwgGAS0Y9EHzJ3Q=";
  };

  buildInputs = with pkgs; [
    bash
  ];

  paths = with pkgs; [
    libnotify
  ];
}
