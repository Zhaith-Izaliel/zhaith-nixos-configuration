{ extra-types, theme, ... }:

{
  options.hellebore = {
    inherit (extra-types) monitors;

    font = extra-types.font {
      name = theme.font.name;
    };
  };

  imports = [
    ./bootloader.nix
    ./development.nix
    ./display-manager.nix
    ./fonts.nix
    ./games.nix
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
    ./users.nix
    ./vm.nix
  ];
}

