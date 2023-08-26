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
    cinnamon.nemo-fileroller
    gnome.file-roller
    blueberry
    fragments
    glab
    gnome.simple-scan
    gparted
    gthumb
    qview
    viu
    power-management
    hyprpicker
    grimblast
    volume-brightness
  ];
}

