{
  config,
  extra-types,
  ...
}: let
  cfg = config.hellebore;
  theme = cfg.theme.themes.${cfg.theme.name};
in {
  options.hellebore = {
    inherit (extra-types) monitors;

    font = extra-types.font {
      name = theme.gtk.font.name;
      size = 12;
      sizeDescription = ''
        Define a global font size for applications. Each
              application's font size can be changed granularly, or set globally using
              this option.'';
      nameDescription = ''
        Define a global font family for applications. Each
              application's font family can be changed granularly, or set globally using
              this option.'';
    };

    theme = {
      inherit (extra-types.theme) themes;
      name = extra-types.theme.name {
        description = "Defines the name of the theme applied globally";
      };
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
    ./shell.nix
    ./sound.nix
    ./ssh.nix
    ./tex.nix
    ./tools.nix
    ./users.nix
    ./vm.nix
  ];
}
