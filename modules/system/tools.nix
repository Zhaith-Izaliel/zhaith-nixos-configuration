{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hellebore.tools;
in {
  options.hellebore.tools = {
    enable = mkEnableOption "Hellebore tools packages";

    etcher.enable = mkEnableOption "Balena Etcher";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        gotop
        qview
        ripgrep
        repgrep
        jq
        neofetch
        zip
        unzip
        pstree
        pciutils
        wget
        curl
        tree
        rar
        unrar
        erdtree
        nix-alien
        file
      ]
      ++ lists.optional cfg.etcher.enable pkgs.etcher;

    programs.nix-ld.enable = true;
  };
}
