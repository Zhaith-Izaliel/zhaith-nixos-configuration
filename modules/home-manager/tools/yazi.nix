{
  pkgs,
  lib,
  config,
  extra-types,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkPackageOption;
  cfg = config.hellebore.tools.yazi;
  theme = config.hellebore.theme.themes.${cfg.theme};
in {
  options.hellebore.tools.yazi = {
    enable = mkEnableOption "Hellebore's Yazi configuration";

    package = mkPackageOption pkgs "yazi" {};

    theme = extra-types.theme.name {
      default = config.hellebore.theme.name;
      description = "Defines Yazi's theme. Default to global theme.";
    };
  };

  config = mkIf cfg.enable {
    programs.yazi = {
      inherit (cfg) package;
      enable = true;

      enableBashIntegration = config.programs.bash.enable;
      enableZshIntegration = config.programs.zsh.enable;
      enableFishIntegration = config.programs.fish.enable;
      enableNushellIntegration = config.programs.nushell.enable;
    };

    xdg.configFile."yazi/theme.toml".source = theme.yazi.file;
  };
}
