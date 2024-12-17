{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkPackageOption mkOption types;
  cfg = config.hellebore.multimedia.obs-studio;
in {
  options.hellebore.multimedia.obs-studio = {
    enable = mkEnableOption "Hellebore OBS Studio configuration";

    package = mkPackageOption pkgs "obs-studio" {};

    plugins = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "The plugins to install to OBS Studio";
    };
  };

  config = mkIf cfg.enable {
    programs.obs-studio = {
      inherit (cfg) package plugins;
      enable = true;
    };
  };
}
