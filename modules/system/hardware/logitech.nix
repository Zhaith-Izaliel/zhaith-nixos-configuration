{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.hardware.logitech;
in

{
  options.hellebore.hardware.logitech = {
    enable = mkEnableOption "Logitech hardware support with Solaar";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      solaar
    ];

    services.udev = {
      enable = true;
      packages = with pkgs; [ logitech-udev-rules ];
    };
  };
}

