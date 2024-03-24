{
  os-config,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hellebore.desktop-environment.network;
in {
  options.hellebore.desktop-environment.network = {
    enable = mkEnableOption "Hellebore's Network configuration";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = os-config.networking.networkmanager.enable;
        message = "Network Manager should be enabled to allow Hellebore's
        network support.";
      }
    ];

    home.packages = with pkgs; [
      networkmanagerapplet
    ];
  };
}
