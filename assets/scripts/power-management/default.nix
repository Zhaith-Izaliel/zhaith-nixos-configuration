{ pkgs }:

pkgs.callPackage ../builder.nix rec {
  pname = "power-management";

  version = "v2.2.2";

  src = pkgs.fetchFromGitLab {
    repo = pname;
    owner = "Zhaith-Izaliel";
    rev = version;
    sha256 = "sha256-celAGElQzhaapBWrMmK+9Fy03CoRHEosdGTrk8NUEUw=";
  };

  buildInputs = with pkgs; [
    bash
  ];

  paths = with pkgs; [
    libnotify
    gnugrep
    sudo
    coreutils
  ];
}

