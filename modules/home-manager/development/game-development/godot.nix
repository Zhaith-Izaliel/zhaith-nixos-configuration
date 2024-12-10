{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkPackageOption mkEnableOption mkIf optional;
  cfg = config.hellebore.development.game-development.godot;
in {
  options.hellebore.development.game-development.godot = {
    enable = mkEnableOption "Godot, a free and Open Source 2D and 3D game engine";

    package = mkPackageOption pkgs "godot_4" {};

    export-templates = {
      enable = mkEnableOption "Godot export templates";

      package = mkPackageOption pkgs "godot_4-export-templates" {};
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      [cfg.package]
      ++ (optional cfg.export-templates.enable cfg.export-templates.package);
  };
}
