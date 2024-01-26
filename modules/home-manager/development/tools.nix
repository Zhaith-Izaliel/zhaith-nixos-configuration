{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.development.tools;
in
{
  options.hellebore.development.tools = {
    enable = mkEnableOption "Hellebore development tools";

    direnv = {
      enable = mkEnableOption "Direnv and Nix-Direnv integrations";
      enableLogs = mkEnableOption "Direnv Logs when getting in a Direnv
    directory";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      onefetch
    ];

    home.sessionVariables = mkIf (!cfg.direnv.enableLogs) {
      DIRENV_LOG_FORMAT = "";
    };

    programs.direnv = mkIf cfg.direnv.enable {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}

