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
        Defines a global font size for applications. Each
        application's font size can be changed granularly, or set globally using
        this option.
      '';
      nameDescription = ''
        Defines a global font family for applications. Each
        application's font family can be changed granularly, or set globally using
        this option.
      '';
    };

    cursor = extra-types.cursor {
      name = theme.gtk.cursorTheme.name;
      size = 24;
      sizeDescription = ''
        Defines a global cursor size for applications. Each
        application's cursor size can be changed granularly, or set globally using
        this option.
      '';
      nameDescription = ''
        Defines a global cursor theme for applications. Each
        application's cursor theme can be changed granularly, or set globally using
        this option.
      '';
    };

    theme = {
      inherit (extra-types.theme) themes;
      name = extra-types.theme.name {
        description = "Defines the name of the theme applied globally";
        default = "catppuccin-macchiato";
      };
    };
  };

  imports = [
    ./bootloader.nix
    ./development.nix
    ./display-manager.nix
    ./fonts.nix
    ./games
    ./gnupg.nix
    ./graphics.nix
    ./hardware
    ./hyprland.nix
    ./locale.nix
    ./network.nix
    ./power-management.nix
    ./power-profiles.nix
    ./shell.nix
    ./sound.nix
    ./ssh.nix
    ./tex.nix
    ./tools.nix
    ./vm.nix
  ];
}
