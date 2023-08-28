{ config, lib, ... }:

with lib;

let
  cfg = config.hellebore.development.lorri;
in
{
  options.hellebore.development.lorri = {
    enable = mkEnableOption "Hellebore Lorri configuration";
  };

  config = mkIf cfg.enable {
    services.lorri = {
      enable = true;
      enableNotifications = true;
    };
  };
}

