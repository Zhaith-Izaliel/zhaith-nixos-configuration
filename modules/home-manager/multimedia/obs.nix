{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkPackageOption mkOption types optional;
  cfg = config.hellebore.multimedia.obs-studio;
in {
  options.hellebore.multimedia.obs-studio = {
    enable = mkEnableOption "OBS Studio configuration";

    package = mkPackageOption pkgs "obs-studio" {};

    plugins = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "The plugins to install to OBS Studio";
    };

    cli = {
      enable = mkEnableOption "OBS Studio Websocket CLI";

      package = mkPackageOption pkgs "obs-do" {};
    };
  };

  config = mkIf cfg.enable {
    home.packages = optional cfg.cli.enable cfg.cli.package;

    programs.obs-studio = {
      inherit (cfg) package plugins;
      enable = true;
    };
  };
}
