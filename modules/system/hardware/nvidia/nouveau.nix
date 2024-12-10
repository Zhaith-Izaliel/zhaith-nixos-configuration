{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.hellebore.hardware.nvidia.nouveau;
in {
  options.hellebore.hardware.nvidia.nouveau = {
    enable = mkEnableOption "Nouveau drivers for Nvidia";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.hellebore.graphics.enable;
        message = "You must enable graphics support for Nouveau.";
      }
      {
        assertion = cfg.enable -> !config.hellebore.hardware.nvidia.proprietary.enable;
        message = "Nouveau and the proprietary Nvidia drivers are mutually exclusive, you should enable only one of them.";
      }
    ];

    services.xserver.videoDrivers = ["nouveau"];
  };
}
