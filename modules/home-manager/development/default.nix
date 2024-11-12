{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options.hellebore.development = {
    codeDirectory = mkOption {
      type = types.nonEmptyStr;
      default = "~/Development";
      description = "Define the directory containing all your source codes.";
    };
  };

  imports = [
    ./bat.nix
    ./erd.nix
    ./git
    ./tools.nix
  ];
}
