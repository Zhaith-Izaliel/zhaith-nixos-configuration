{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hellebore.tools;
in {
  options.hellebore.tools = {
    enable = mkEnableOption "Hellebore tools packages";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
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
      nix-alien
      file
      bandwhich
      dust
    ];

    programs.nix-ld.enable = true;
  };
}
