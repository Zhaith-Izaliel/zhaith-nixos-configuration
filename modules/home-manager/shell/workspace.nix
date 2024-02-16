{
  pkgs,
  lib,
  config,
  extra-types,
  ...
}: let
  inherit (lib) mkIf mkOption types mkEnableOption;

  cfg = config.hellebore.shell.workspace;
  theme = config.hellebore.theme.themes.${cfg.theme}.zellij;
in {
  options.hellebore.shell.workspace = {
    enable = mkEnableOption "Hellebore's Terminal Workspace/Multiplexer";

    package = mkOption {
      type = types.package;
      default = pkgs.zellij;
      description = "The package of the Terminal Workspace/Multiplexer";
    };

    font = extra-types.font {
      size = config.hellebore.font.size;
      sizeDescription = "Set the terminal Workspace/Multiplexer font size.";
      name = "FiraMono Nerd Font";
      nameDescription = "Set the terminal Workspace/Multiplexer font family.";
    };

    theme = extra-types.theme.name {
      default = config.hellebore.theme.name;
      description = "Defines the terminal Workspace/Multiplexer theme.";
    };
  };

  config = mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      package = cfg.package;

      enableZshIntegration = config.programs.zsh.enable;
      enableFishIntegration = config.programs.fish.enable;
      enableBashIntegration = config.programs.bash.enable;

      settings = {
        inherit (theme) theme;
        on_force_close = "quit";
      };
    };
  };
}
