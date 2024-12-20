{
  extra-types,
  os-config,
  ...
}: {
  options.hellebore = {
    monitors =
      extra-types.monitors
      // {
        default = os-config.hellebore.monitors;
      };

    font = extra-types.font {
      inherit (os-config.hellebore.font) name size;
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
        default = os-config.hellebore.theme.name;
        description = "Defines the name of the theme applied globally";
      };
    };
  };
  imports = [
    ./desktop-environment
    ./development
    ./games.nix
    ./locale.nix
    ./multimedia
    ./shell
    ./ssh.nix
    ./tools
  ];
}
