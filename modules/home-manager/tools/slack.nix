{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkPackageOption;
  cfg = config.hellebore.tools.slack;
in {
  options.hellebore.tools.slack = {
    enable = mkEnableOption "Slack";

    package = mkPackageOption pkgs "slack" {};
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];
  };
}
