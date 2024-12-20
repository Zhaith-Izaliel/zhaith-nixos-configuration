{
  config,
  lib,
  pkgs,
  extra-types,
  ...
}: let
  inherit (lib) mkEnableOption mkPackageOption mkOption types mkIf;
  cfg = config.hellebore.development.bat;
  theme = config.hellebore.theme.themes.${cfg.theme};
in {
  options.hellebore.development.bat = {
    enable = mkEnableOption "Hellebore's Bat configuration";

    package = mkPackageOption pkgs "bat" {};

    extraPlugins = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Extra plugins to add alongside the default ones.";
    };

    theme = extra-types.theme.name {
      default = config.hellebore.theme.name;
      description = "Defines Bat's theme. Default to global theme.";
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

      extraPackages = with pkgs.bat-extras;
        [
          batdiff
          batgrep
          batman
        ]
        ++ cfg.extraPlugins;

      config = {
        theme = theme.bat.name;
      };
    };
  };
}
