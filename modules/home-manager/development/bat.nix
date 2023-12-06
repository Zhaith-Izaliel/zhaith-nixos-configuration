{ config, lib, pkgs, theme, ... }:

with lib;

let
  cfg = config.hellebore.development.bat;
in
{
  options.hellebore.development.bat = {
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
        "${theme.bat.name}" = {
          inherit (theme.bat) src file;
        };
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

