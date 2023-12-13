{ config, lib, ... }:

with lib;

let
  cfg = config.hellebore.hardware.printing;
in
{
  options.hellebore.hardware.printing = {
    enable = mkEnableOption "Printing support";
    drivers = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Drivers packages in case your printer doesn't support the
      IPP everywhere protocol";
    };
  };

  config = mkIf cfg.enable {
    services = {
      printing = {
        enable = true;
        drivers = cfg.drivers;
      };

      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };
  };
}

