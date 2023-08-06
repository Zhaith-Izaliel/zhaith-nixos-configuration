{ pkgs }:

pkgs.callPackage ../builder.nix rec {
  pname = "volume-brightness";

  version = "v1.0.0";

  src = pkgs.fetchFromGitLab {
    repo = pname;
    owner = "Zhaith-Izaliel";
    rev = version;
    sha256 = "sha256-z7ulwjulMlDfvyty8N+WRo1DBqjFComADjB1Ko4sH/w=";
  };

  buildInputs = with pkgs; [
    bash
  ];

  paths = with pkgs; [
    brightnessctl
    gawk
    wireplumber
    bc
    dunst
    gnused
  ];
}

