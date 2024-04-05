{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf optionals optional mkDefault;
  cfg = config.hellebore.development;
in {
  options.hellebore.development = {
    enable = mkEnableOption "Hellebore development packages";

    enablePodman = mkEnableOption "Docker service and tools";

    enableDocumentation = mkEnableOption "Documentations and MAN pages";
  };

  config = mkIf cfg.enable {
    virtualisation.podman = {
      enable = mkDefault cfg.enablePodman;
      dockerSocket.enable = cfg.enablePodman;
      dockerCompat = cfg.enablePodman;
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
