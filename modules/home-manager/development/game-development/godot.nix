{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkPackageOption mkIf;
  cfg = config.hellebore.development.game-development.godot;
in {
  options.hellebore.development.game-development.godot = {
    enable = mkEnableOption "Hellebore's Bat configuration";

    package = mkPackageOption pkgs "godot_4" {};
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];
  };
}
