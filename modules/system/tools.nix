{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf optional;
  cfg = config.hellebore.tools;
in {
  options.hellebore.tools = {
    enable = mkEnableOption "Hellebore tools packages";

    nix-alien.enable = mkEnableOption "Nix Alien";
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      (with pkgs; [
        jq
        gotop
        ripgrep
        repgrep
        zip
        unzip
        pstree
        pciutils
        wget
        curl
        rar
        unrar
        erdtree
        file
        bandwhich
        dust
        agenix
        nvtopPackages.full
      ])
      ++ optional cfg.nix-alien.enable pkgs.nix-alien;

    programs.nix-ld.enable = cfg.nix-alien.enable;
  };
}
