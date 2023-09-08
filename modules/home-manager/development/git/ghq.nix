{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.development.git.ghq;
in
{
  options.hellebore.development.git.ghq = {
    enable = mkEnableOption "GHQ configuration";

    codeDirectory = mkOption {
      type = types.nonEmptyStr;
      default = config.hellebore.development.codeDirectory;
      description = "Directory containing GHQ projects";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> programs.git.enable;
        message = "You need to enable git for GHQ to work.";
      }
    ];

    home.packages = [ pkgs.ghq ];

    programs.git.extraConfig.ghq = {
      root = cfg.codeDirectory;
    };
  };
}

