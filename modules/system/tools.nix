{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.tools;
in
{
  options.hellebore.tools = {
    enable = mkEnableOption "Hellebore tools packages";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gotop
      ripgrep
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
    ];

    programs.nix-ld.enable = true;
  };
}

