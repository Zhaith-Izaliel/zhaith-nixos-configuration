{ pkgs, ... }:

let
  nix-alien-pkgs = import (
    fetchTarball {
      url = "https://github.com/thiagokokada/nix-alien/tarball/master";
      sha256 = "1mb9m3cahjq2g37a0p94ydskwcxr9365zngilxd9h1qhi4fvf5jb";
    }
  ) { };
in
{
  environment.systemPackages = with nix-alien-pkgs; [
    nix-alien
    nix-index-update
    pkgs.nix-index # not necessary, but recommended
  ];

  # Optional, but this is needed for `nix-alien-ld` command
  programs.nix-ld.enable = true;
}
