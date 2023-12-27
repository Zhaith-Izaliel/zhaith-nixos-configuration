{ extra-types, os-config, ... }:

{
  options.hellebore = {
    font = extra-types.font {
      size = os-config.hellebore.font.size;
      sizeDescription = "Define a global font size for applications. Each
      application's font size can be changed granularly, or set globally using
      this option.";
      name = os-config.hellebore.font.name;
      nameDescription = "Define a global font family for applications. Each
      application's font family can be changed granularly, or set globally using
      this option.";
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

