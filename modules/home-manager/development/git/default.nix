{
  config,
  lib,
  pkgs,
  extra-types,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption mkPackageOption types;
  cfg = config.hellebore.development.git;
  theme = config.hellebore.theme.themes.${cfg.gitui.theme};
in {
  imports = [
    ./commitizen.nix
    ./h.nix
  ];

  options.hellebore.development.git = {
    enable = mkEnableOption "Hellebore's Git configuration";

    package = mkPackageOption pkgs "git" {};

    userName = mkOption {
      type = types.str;
      default = "Virgil Ribeyre";
      description = "Git user name.";
    };

    userEmail = mkOption {
      type = types.str;
      default = "virgil.ribeyre@protonmail.com";
      description = "Git user email.";
    };

    gitui = {
      enable = mkEnableOption "Hellebore's Gitui configuration";

      theme = extra-types.theme.name {
        default = config.hellebore.theme.name;
        description = "Defines GitUI theme name.";
      };

      package = mkPackageOption pkgs "gitui" {};
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gitAndTools.gitflow
      git-ignore
      git-graph
    ];

    programs.git = {
      inherit (cfg) userEmail userName package;
      enable = true;
      extraConfig = {
        push.autoSetupRemote = true;
        init.defaultBranch = "master";
        pull.rebase = false;
      };
    };

    programs.gitui = mkIf cfg.gitui.enable {
      inherit (cfg.gitui) package;
      enable = true;
      theme = builtins.readFile theme.gitui.file;
    };
  };
}
