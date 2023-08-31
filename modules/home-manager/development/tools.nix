{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.development.tools;
in
{
  options.hellebore.development.tools = {
    enable = mkEnableOption "Hellebore development tools";

    enableLorri = mkEnableOption "Lorri Nix Shell service";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      direnv
      onefetch
      universal-ctags
    ];

    services.lorri = {
      enable = cfg.enableLorri;
      enableNotifications = true;
    };
  };
}

