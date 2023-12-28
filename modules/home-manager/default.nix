{ extra-types, os-config, ... }:

{
  options.hellebore = {
    inherit (extra-types) monitors;

    font = extra-types.font {
      inherit (os-config.hellebore.font) name size;
      sizeDescription = "Define a global font size for applications. Each
      application's font size can be changed granularly, or set globally using
      this option.";
      nameDescription = "Define a global font family for applications. Each
      application's font family can be changed granularly, or set globally using
      this option.";
    };

    theme = {
      inherit (extra-types.theme) themes;
      name = extra-types.theme.name {
        name = os-config.hellebore.theme.name;
        description = "Defines the name of the theme applied globally";
      };
    };
  };
  imports = [
    ./development
    ./shell
    ./desktop-environment
    ./games.nix
    ./tools
    ./multimedia
  ];
}

