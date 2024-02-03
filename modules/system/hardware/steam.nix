{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hellebore.hardware.steam;
in {
  options.hellebore.hardware.steam = {
    enable = mkEnableOption "Hellebore's Steam Hardware support";
  };

  config = mkIf cfg.enable {
    hardware.steam.enable = true;
  };
}
