{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hellebore.hardware.logitech;
in {
  options.hellebore.hardware.logitech = {
    enable = mkEnableOption "Logitech hardware support";
    lcd.enable = mkEnableOption "Logitech LCD hardware support";
    wireless.enable = mkEnableOption "Logitech wireless hardware support";
  };

  config = mkIf cfg.enable {
    hardware.logitech = {
      wireless = mkIf cfg.wireless.enable {
        enable = true;
        enableGraphical = true;
      };

      lcd = mkIf cfg.lcd.enable {
        enable = true;
        startWhenNeeded = true;
      };
    };
  };
}
