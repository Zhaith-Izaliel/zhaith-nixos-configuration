{
  os-config,
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hellebore.desktop-environment.cloud;
in {
  options.hellebore.desktop-environment.cloud = {
    enable = mkEnableOption "Hellebore cloud saves configuration";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion =
          cfg.enable
          -> os-config.services.gnome.gnome-keyring.enable;
        message = "Gnome Keyring should be enabled to store passwords for
        Nextcloud client.";
      }
    ];

    services.nextcloud-client = {
      enable = true;
      startInBackground = true;
    };
  };
}
