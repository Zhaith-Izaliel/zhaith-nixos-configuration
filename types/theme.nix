{ name, lib }:

let
  inherit (lib) types mkOption mkEnableOption;
in
{
  # TEST: Used for testing
  # TEMP: Should be removed later
  themes = mkOption {
    type = types.attrsOf types.any;
    default = {};
    description = "The attribute set containing every defined themes";
  };
}

