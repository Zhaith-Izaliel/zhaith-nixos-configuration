{ pkgs, ... }:

{
  imports = [
    ./art.nix
    ./commitlint.nix
    ./discord.nix
    ./erd.nix
    ./multimedia.nix
    ./obs.nix
    ./office.nix
    ./reMarkable.nix
  ];

  home.packages = with pkgs; [
    cinnamon.nemo
    fragments
    glab
    gnome.simple-scan
    gparted
    gthumb
    qview
    tape
    viu
  ];
}

