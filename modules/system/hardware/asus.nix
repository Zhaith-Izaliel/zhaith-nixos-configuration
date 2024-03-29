{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hellebore.hardware.asus;
in {
  options.hellebore.hardware.asus = {
    enable = mkEnableOption "Hellebore's Asus Hardware support";
  };

  config = mkIf cfg.enable {
    services = {
      asusd = {
        enable = true;
        enableUserService = true;
      };
    };
  };
}
