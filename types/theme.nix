{
  name,
  lib,
}: let
  inherit (lib) types mkOption mkEnableOption;
in {
  themes = mkOption {
    type = types.attrsOf types.any;
    default = {};
    description = "The attribute set containing every defined themes";
  };
}
