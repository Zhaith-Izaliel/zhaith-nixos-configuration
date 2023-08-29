{ pkgs, ... }:

{
  imports = [
    ./art.nix
    ./bat.nix
    ./commitlint.nix
    ./discord.nix
    ./erd.nix
    ./gitui.nix
    ./multimedia.nix
    ./obs.nix
    ./office.nix
    ./reMarkable.nix
    ./networkmanager.nix
  ];

  home.packages = with pkgs; [
      ];
}

