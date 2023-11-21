{ lib, ... }:

{
  options.hellebore = {
    fontSize = lib.mkOption {
      type = lib.types.int;
      default = 12;
      description = "Define a global font size for applications. Each
      application font size can be changed granularly, or set globally using
      this option.";
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

