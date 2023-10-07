{ lib, ... }:

{
  options.hellebore = {
    fontSize = lib.mkOption {
      type = lib.types.int;
      default = 12;
      description = "Hellebore global applications font size";
    };
  };

  imports = [
    ./bootloader.nix
    ./development.nix
    ./display-manager.nix
    ./fonts.nix
    ./hardware
    ./hyprland.nix
    ./kernel.nix
    ./locale.nix
    ./network.nix
    ./opengl.nix
    ./power-management.nix
    ./server/inadyn.nix
    ./shell.nix
    ./sound.nix
    ./ssh.nix
    ./tex.nix
    ./tools.nix
    ./vm.nix
  ];
}

