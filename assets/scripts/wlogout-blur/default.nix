{ pkgs }:

pkgs.callPackage ../builder.nix rec {
  pname = "wlogout-blur";

  version = "v1.0.0";

  src = pkgs.fetchFromGitLab {
    repo = pname;
    owner = "Zhaith-Izaliel";
    rev = version;
    sha256 = "";
  };

  buildInputs = with pkgs; [
    bash
  ];

  paths = with pkgs; [
    imagemagick
    wlogout
    grimblast
  ];
}

