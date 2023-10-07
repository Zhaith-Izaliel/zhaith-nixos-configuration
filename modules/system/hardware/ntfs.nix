{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.hardware.ntfs;
in
{
  options.hellebore.hardware.ntfs = {
    enable = mkEnableOption "NTFS support";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ntfs3g
    ];

    boot.supportedFilesystems = [ "ntfs" ];
  };
}

