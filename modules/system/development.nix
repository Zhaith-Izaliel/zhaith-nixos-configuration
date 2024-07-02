{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf optionals optional;
  cfg = config.hellebore.development;
in {
  options.hellebore.development = {
    enable = mkEnableOption "Hellebore development packages";

    enablePodman = mkEnableOption "Docker service and tools";

    enableDocumentation = mkEnableOption "Documentations and MAN pages";
  };

  config = mkIf cfg.enable {
    virtualisation.podman = mkIf cfg.enablePodman {
      enable = true;
      dockerSocket.enable = true;
      dockerCompat = true;
    };

    documentation.dev.enable = cfg.enableDocumentation;

    environment.systemPackages = with pkgs;
      [
        helix
        git
        gnumake
      ]
      ++ (optional cfg.enablePodman pkgs.podman-compose)
      ++ (optionals cfg.enableDocumentation [
        man-pages
        man-pages-posix
      ]);
  };
}
