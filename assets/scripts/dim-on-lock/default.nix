{ pkgs }:

pkgs.callPackage ../builder.nix rec {
  pname = "dim-on-lock";

  version = "v1.1.0";

  src = pkgs.fetchFromGitLab {
    repo = pname;
    owner = "Zhaith-Izaliel";
    rev = version;
    sha256 = "sha256-PkkLHkwPYcsfMf5LkeK8w8ZxpKxVuiWq3c3FK5MODL8=";
  };

  buildInputs = with pkgs; [
    bash
  ];

  paths = with pkgs; [
    brightnessctl
  ];
}

