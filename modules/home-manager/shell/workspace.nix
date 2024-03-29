{
  pkgs,
  lib,
  config,
  extra-types,
  ...
}: let
  inherit (lib) mkIf mkPackageOption mkEnableOption cleanSource;

  cfg = config.hellebore.shell.workspace;
  theme = config.hellebore.theme.themes.${cfg.theme};
  layouts = cleanSource ../../../assets/zellij-layouts;
in {
  options.hellebore.shell.workspace = {
    enable = mkEnableOption "Hellebore's Terminal Workspace/Multiplexer";

    package = mkPackageOption pkgs "zellij" {};

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
    home.sessionVariables = {
      ZELLIJ_AUTO_ATTACH = "true";
      # ZELLIJ_AUTO_EXIT = "true";
    };

    xdg.configFile."zellij/layouts".source = layouts;

    home.shellAliases = {
      zlayout = "zellij action new-tab --layout";
    };

    programs.zellij = {
      enable = true;
      package = cfg.package;

      enableZshIntegration = config.programs.zsh.enable;
      enableFishIntegration = config.programs.fish.enable;
      enableBashIntegration = config.programs.bash.enable;

      settings = {
        inherit (theme.zellij) theme;
        keybinds = {
          "shared_except \"locked\"" = {
            "bind \"Ctrl g\"" = {SwitchToMode = "Locked";};
            "bind \"Ctrl q\"" = {Quit = {};};
            "bind \"Alt n\"" = {NewPane = {};};
            "bind \"Alt h\" \"Alt Left\"" = {MoveFocusOrTab = "Left";};
            "bind \"Alt l\" \"Alt Right\"" = {MoveFocusOrTab = "Right";};
            "bind \"Alt j\" \"Alt Down\"" = {MoveFocus = "Down";};
            "bind \"Alt k\" \"Alt Up\"" = {MoveFocus = "Up";};
            "bind \"Alt -\"" = {Resize = "Decrease";};
            "bind \"Alt =\" \"Alt +\"" = {Resize = "Increase";};
            "bind \"Alt [\"" = {PreviousSwapLayout = {};};
            "bind \"Alt ]\"" = {NextSwapLayout = {};};
          };
        };
      };
    };
  };
}
