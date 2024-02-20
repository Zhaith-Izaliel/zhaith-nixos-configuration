{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption optionals;
  cfg = config.hellebore.development.tools;
in {
  options.hellebore.development.tools = {
    enable = mkEnableOption "Hellebore development tools";

    direnv = {
      enable = mkEnableOption "Direnv and Nix-Direnv integrations";
      enableLogs = mkEnableOption "Direnv Logs when getting in a Direnv
    directory";
    };
  };

  config = {
    home.packages = optionals cfg.enable (with pkgs; [
      onefetch
      nix-npm-install
    ]);

    home.sessionVariables = mkIf (!cfg.direnv.enableLogs) {
      DIRENV_LOG_FORMAT = "";
    };

    programs.direnv = mkIf cfg.direnv.enable {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
