{ theme }:
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.gitui;
in
{
  options.hellebore.gitui = {
    enable = mkEnableOption "Hellebore's Gitui config";

    package = mkOption {
      type = types.package;
      default = config.programs.gitui.package;
      description = "Override Gitui default package";
    };
  };

  config = mkIf cfg.enable {
    programs.gitui = {
      enable = true;
      package = cfg.package;
      theme = builtins.readFile theme.gitui.file;
    };
  };

}

