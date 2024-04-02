{
  config,
  lib,
  pkgs,
  unstable-pkgs,
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
    environment.systemPackages = with pkgs;
      [
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
        unstable-pkgs.dust
      ]
      ++ optional cfg.nix-alien.enable nix-alien;

    programs.nix-ld.enable = cfg.nix-alien.enable;
  };
}
