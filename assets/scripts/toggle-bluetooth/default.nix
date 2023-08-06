{ pkgs }:

pkgs.callPackage ../builder.nix rec {
  pname = "toggle-bluetooth";

  version = "1.0.0";

  src = pkgs.fetchFromGitLab {
    repo = pname;
    owner = "Zhaith-Izaliel";
    rev = "v${version}";
    sha256 = "sha256-gZNGefuArSpWRicPBXUfC28Ilq6kYLBu7PcnSqlQYfw=";
  };

  buildInputs = with pkgs; [
    bash
  ];

  paths = with pkgs; [
    bluez
    bash
    gnugrep
    coreutils
  ];
}

