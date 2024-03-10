{
  pkgs,
  lib,
  config,
  extra-types,
  ...
}: let
  inherit (lib) mkEnableOption mkIf types mkOption;
  cfg = config.hellebore.tools.yazi;
  theme = config.hellebore.theme.themes.${cfg.theme};
in {
  options.hellebore.tools.yazi = {
    enable = mkEnableOption "Hellebore's Yazi configuration";

    package = mkOption {
      type = types.package;
      default = pkgs.yazi;
      description = "Defines the default Yazi package.";
    };

    theme = extra-types.theme.name {
      default = config.hellebore.theme.name;
      description = "Defines Bat's theme. Default to global theme.";
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
