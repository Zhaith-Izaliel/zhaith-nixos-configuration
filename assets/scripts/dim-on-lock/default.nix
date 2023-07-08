{ pkgs }:

pkgs.callPackage ../builder.nix rec {
  pname = "dim-on-lock";

  version = "v1.0.0";

  src = pkgs.fetchFromGitLab {
    repo = "dim-on-lock";
    owner = "Zhaith-Izaliel";
    rev = version;
    sha256 = "sha256-LAMiY4E8CG0WaanK1+4XF0zG/h4uZf9ypkEIkfNB0d0=";
  };

  buildInputs = with pkgs; [
    bash
  ];

  paths = with pkgs; [
    brightnessctl
  ];
}

