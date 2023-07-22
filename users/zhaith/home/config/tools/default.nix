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
    cinnamon.nemo
    blueberry
    fragments
    glab
    gnome.simple-scan
    gparted
    gthumb
    qview
    tape
    viu
    power-management
    hyprpicker
    grimblast
  ];
}

