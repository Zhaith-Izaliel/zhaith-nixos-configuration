{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf optionals;
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
      defaultNetwork.settings = {
        # Required for container networking to be able to use names.
        dns_enabled = true;
      };
    };

    documentation.dev.enable = cfg.enableDocumentation;

    environment.variables = {
      EDITOR = "hx";
    };

    environment.systemPackages =
      (with pkgs; [
        helix
        git
        gnumake
        nix-npm-install
      ])
      ++ (optionals cfg.enablePodman (with pkgs; [
        podman-compose
        compose2nix
      ]))
      ++ (optionals cfg.enableDocumentation (with pkgs; [
        man-pages
        man-pages-posix
      ]));
  };
}
