{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkPackageOption;
  cfg = config.hellebore.tools.tasks;
in {
  options.hellebore.tools.tasks = {
    enable = mkEnableOption "Hellebore's tasks management";

    package = mkPackageOption pkgs "taskwarrior" {};
  };

  config = mkIf cfg.enable {
    programs.taskwarrior = {
      inherit (cfg) package;
      enable = true;
    };
  };
}
