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

    enableDocker = mkEnableOption "Docker service and tools";

    enableDocumentation = mkEnableOption "Documentations and MAN pages";
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = mkDefault cfg.enableDocker;
    documentation.dev.enable = cfg.enableDocumentation;

    environment.systemPackages = with pkgs;
      [
        helix
        git
        gnumake
      ]
      ++ (optional cfg.enableDocker pkgs.docker-compose)
      ++ (optionals cfg.enableDocumentation [
        man-pages
        man-pages-posix
      ]);
  };
}
