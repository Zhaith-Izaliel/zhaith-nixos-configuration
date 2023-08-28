{ theme }:
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.development.git;
in
{
  options.hellebore.development.git = {
    enable = mkEnableOption "Hellebore's Git configuration";

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

      package = mkOption {
        type = types.package;
        default = pkgs.gitui;
        description = "Override Gitui default package";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gitAndTools.gitflow
      git-ignore
    ];

    programs.git = {
      inherit (cfg) userEmail userName;
      enable = true;
      extraConfig = {
        push.autoSetupRemote = true;
        init.defaultBranch = "master";
        pull.rebase = false;
      };
    };

    programs.gitui = {
      enable = cfg.gitui.enable;
      package = cfg.gitui.package;
      theme = builtins.readFile theme.gitui.file;
    };
  };
}

