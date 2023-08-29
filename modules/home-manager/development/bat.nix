{ config, lib, pkgs, theme, ... }:

with lib;

let
  cfg = config.hellebore.bat;
in
{
  options.hellebore.bat = {
    enable = mkEnableOption "Hellebore's Bat configuration";

    package = mkOption {
      type = types.package;
      default = pkgs.bat;
      description = "The bat package to use.";
    };

    extraPlugins = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Extra plugins to add alongside the default ones.";
    };
  };

  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;

      themes = {
        "${theme.bat.name}" = builtins.readFile theme.bat.file;
      };

      extraPackages = with pkgs.bat-extras; [
        batdiff
      ] ++ cfg.extraPlugins;

      config = {
        theme = theme.bat.name;
      };
    };
  };
}

