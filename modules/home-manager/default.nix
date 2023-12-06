{ extraTypes, ... }:

{
  options.hellebore = {
    inherit (extraTypes) fontSize monitors;
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

