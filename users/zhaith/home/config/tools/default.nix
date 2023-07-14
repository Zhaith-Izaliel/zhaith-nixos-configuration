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
    ./thunar.nix
    ./blueman.nix
    ./grimblast.nix
    ./flameshot.nix
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
    power-management
    hyprpicker
  ];
}

