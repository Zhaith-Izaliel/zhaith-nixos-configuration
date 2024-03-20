{
  config,
  lib,
  pkgs,
  extra-types,
  ...
}: let
  inherit (lib) mkEnableOption mkPackageOption mkIf;
  cfg = config.hellebore.shell.prompt;
  theme = config.hellebore.theme.themes.${cfg.theme};
in {
  options.hellebore.shell.prompt = {
    enable = mkEnableOption "Starship Hellebore's config";

    package = mkPackageOption pkgs "starship" {};

    theme = extra-types.theme.name {
      default = config.hellebore.theme.name;
      description = "Defines Starship's theme.";
    };
  };

  config = mkIf cfg.enable {
    programs.starship = {
      inherit (cfg) package;
      inherit (theme.starship) settings;
      enable = true;
    };
  };
}
