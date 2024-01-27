{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hellebore.desktop-environment.widget;
in {
  options.hellebore.desktop-environment.widget = {
    enable = mkEnableOption "Hellebore's desktop environment widgets";
  };

  config = mkIf cfg.enable {
    programs.eww = {
      enable = true;
      configDir = ./config;
    };
  };
}
