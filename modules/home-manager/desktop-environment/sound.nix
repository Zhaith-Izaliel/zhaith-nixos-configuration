{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.hellebore.desktop-environment.sound;
in {
  options.hellebore.desktop-environment.sound = {
    enable = mkEnableOption "Hellebore's sound apps";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      pavucontrol
    ];
  };
}
