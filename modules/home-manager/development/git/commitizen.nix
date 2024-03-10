{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption mkEnableOption mkIf types;
  cfg = config.hellebore.development.git.commitizen;
in {
  options.hellebore.development.git.commitizen = {
    enable = mkEnableOption "Hellebore's Commitizen support";

    package = mkOption {
      type = types.package;
      default = pkgs.cz-cli;
      description = "The default commitizen package to use.";
    };

    setUpAlias =
      mkEnableOption null
      // {
        description = "Enable the alias `gc` to refer to `cz` directly when commiting.";
      };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];
    home.shellAliases = mkIf cfg.setUpAlias {
      gc = "cz";
    };
  };
}
