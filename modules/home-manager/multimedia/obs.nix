{
  os-config,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf optional;
  cfg = config.hellebore.multimedia.obs;
in {
  options.hellebore.multimedia.obs = {
    enable = mkEnableOption "Hellebore OBS Studio configuration";
  };

  config = mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      plugins = optional os-config.hellebore.vm.enable pkgs.obs-studio-plugins.looking-glass-obs;
    };
  };
}
