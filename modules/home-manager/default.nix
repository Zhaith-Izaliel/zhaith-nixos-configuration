{ extra-types, os-config, ... }:

{
  options.hellebore = {
    font = extra-types.font {
      size = os-config.hellebore.font.size;
      name = os-config.hellebore.font.name;
    };

    monitors = extra-types.monitors // {
      default = os-config.hellebore.monitors;
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

