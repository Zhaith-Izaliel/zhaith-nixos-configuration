{ config, lib, ... }:

let
  cfg = config.hellebore.development;
in
{
  options.hellebore.development = {
    codeDirectory = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "~/Development";
      description = "Define the directory containing all your source codes.";
    };
  };

  imports = [
    ./bat.nix
    ./git
    ./erd.nix
    ./tools.nix
  ];
}

