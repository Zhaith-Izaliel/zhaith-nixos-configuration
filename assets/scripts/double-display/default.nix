{ pkgs }:

pkgs.callPackage ../builder.nix rec {
  pname = "double-display";
  version = "v1.0.2";

  src = pkgs.fetchFromGitLab {
    repo = pname;
    owner = "Zhaith-Izaliel";
    rev = version;
    sha256 = "sha256-AZPGAUpm9Pr/RwnQBD0epN8M9fkVE1OsMf/FDdCAI6E=";
  };

  buildInputs = [
    pkgs.bash
  ];

  paths = [
    pkgs.xorg.xrandr
  ];
}

