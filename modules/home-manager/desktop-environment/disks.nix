{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hellebore.desktop-environment.disks;
in {
  options.hellebore.desktop-environment.disks = {
    enable = mkEnableOption "Hellebore's disks management tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gparted
    ];
  };
}
