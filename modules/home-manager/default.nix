{ extraTypes, osConfig, ... }:

{
  options.hellebore = {
    fontSize = extraTypes.fontSize // {
      default = osConfig.hellebore.fontSize;
    };

    monitors = extraTypes.monitors // {
      default = osConfig.hellebore.monitors;
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

