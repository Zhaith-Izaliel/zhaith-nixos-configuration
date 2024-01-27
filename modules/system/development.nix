{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hellebore.development;
in {
  options.hellebore.development = {
    enable = mkEnableOption "Hellebore development packages";

    enableDocker = mkEnableOption "Docker service and tools";

    enableDocumentation = mkEnableOption "Documentations and MAN pages";
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = cfg.enableDocker;
    documentation.dev.enable = cfg.enableDocumentation;

    environment.systemPackages = with pkgs;
      [
        neovim
        git
      ]
      ++ (lists.optional cfg.enableDocker pkgs.docker-compose)
      ++ (lists.optionals cfg.enableDocumentation (with pkgs; [
        man-pages
        man-pages-posix
      ]));
  };
}
