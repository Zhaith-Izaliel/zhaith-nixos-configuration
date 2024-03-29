{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkPackageOption mkIf;
  cfg = config.hellebore.tools.affine;
in {
  options.hellebore.tools.affine = {
    enable = mkEnableOption "AFFiNE, an All-In-One KnowledgeOS";

    package = mkPackageOption pkgs "affine" {};
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];
  };
}
