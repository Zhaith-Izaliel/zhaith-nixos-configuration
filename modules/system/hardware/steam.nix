{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hellebore.hardware.steam;
in {
  options.hellebore.hardware.steam = {
    enable = mkEnableOption "Hellebore's Steam Hardware support";
  };

  config = mkIf cfg.enable {
    hardware.steam-hardware.enable = true;

    environment.systemPackages = with pkgs; [
      sc-controller
    ];
  };
}
