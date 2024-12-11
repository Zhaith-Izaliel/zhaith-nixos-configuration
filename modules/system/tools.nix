{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf optional mkPackageOption;
  cfg = config.hellebore.tools;
in {
  options.hellebore.tools = {
    enable = mkEnableOption "Hellebore tools packages";

    nix-alien.enable = mkEnableOption "Nix Alien";

    input-remapper = {
      enable = mkEnableOption "input-remapper, an easy to use tool to change the mapping of your input device buttons";

      package = mkPackageOption pkgs "input-remapper" {};
    };
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
        usbutils
        wget
        curl
        rar
        unrar
        erdtree
        file
        bandwhich
        dust
        agenix
        pv
        nvtopPackages.full
      ])
      ++ optional cfg.nix-alien.enable pkgs.nix-alien;

    programs.nix-ld.enable = cfg.nix-alien.enable;

    services.input-remapper = {
      inherit (cfg.input-remapper) enable package;
    };
  };
}
