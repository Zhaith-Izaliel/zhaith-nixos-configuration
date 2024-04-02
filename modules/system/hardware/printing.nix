{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib) mkOption mkEnableOption mkIf types;
  cfg = config.hellebore.hardware.printing;
in {
  options.hellebore.hardware.printing = {
    enable = mkEnableOption "Printing support";

    drivers = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Drivers packages in case your printer doesn't support the
      IPP everywhere protocol";
    };

    numerization.enable = mkEnableOption "Numerization support";
  };

  config = mkIf cfg.enable {
    hardware.sane.enable = cfg.numerization.enable;

    services = {
      printing = {
        enable = true;
        drivers = cfg.drivers;
      };

      avahi =
        {
          enable = true;
          openFirewall = true;
        }
        // (mkIf (builtins.hasAttr "nssmdns4" options.services.avahi) {nssmdns4 = true;});
    };
  };
}
