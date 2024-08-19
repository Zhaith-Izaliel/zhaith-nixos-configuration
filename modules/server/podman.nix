{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hellebore.server.podman;
in {
  options.hellebore.server.podman = {
    enable = mkEnableOption "Podman support for OCI-Containers";
  };

  config = mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;
      autoPrune.enable = true;
      dockerCompat = true;
      defaultNetwork.settings = {
        # Required for container networking to be able to use names.
        dns_enabled = true;
      };
    };
    virtualisation.oci-containers.backend = "podman";
  };
}
