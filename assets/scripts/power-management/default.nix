{ pkgs }:

pkgs.callPackage ../builder.nix rec {
  pname = "power-management";

  version = "v2.2.1";

  src = pkgs.fetchFromGitLab {
    repo = pname;
    owner = "Zhaith-Izaliel";
    rev = version;
    sha256 = "sha256-Jmk/cRGVzpCnQrtzzNw+KDgGxE2vgQ5WYmGRqSHzbvw=";
  };

  buildInputs = with pkgs; [
    bash
  ];

  paths = with pkgs; [
    libnotify
    gnugrep
    sudo
    gawk
    coreutils
  ];
}

