{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkPackageOption;
  cfg = config.hellebore.development.git.commitizen;
in {
  options.hellebore.development.git.commitizen = {
    enable = mkEnableOption "Hellebore's Commitizen support";

    package = mkPackageOption pkgs "commitizen" {};

    setUpAlias =
      mkEnableOption null
      // {
        description = "Enable the alias `gc` to refer to `cz` directly when commiting.";
      };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];
    home.shellAliases = mkIf cfg.setUpAlias {
      gcz = "cz commit";
    };
  };
}
