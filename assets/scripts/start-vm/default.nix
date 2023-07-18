{ pkgs }:

pkgs.callPackage ../builder.nix rec {
  pname = "start-vm";

  version = "v2.2.0";

  src = pkgs.fetchFromGitLab {
    repo = pname;
    owner = "Zhaith-Izaliel";
    rev = version;
    sha256 = "sha256-c/FIIYjsbRK3jQeXjN+8EIkoyTa7CmyB2XSwCIAaiMY=";
  };

  buildInputs = with pkgs; [
    bash
  ];

  paths = with pkgs; [
    virt-manager
    pstree
    libnotify
    looking-glass-client
  ];
}

