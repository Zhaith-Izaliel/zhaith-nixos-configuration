{ pkgs }:

pkgs.callPackage ../builder.nix rec {
  pname = "power-management";

  version = "v1.0.0";

  src = pkgs.fetchFromGitLab {
    repo = "dim-on-lock";
    owner = "Zhaith-Izaliel";
    rev = version;
    sha256 = "";
  };

  buildInputs = with pkgs; [
    bash
  ];

  paths = with pkgs; [
    brightnessctl
  ];
}

