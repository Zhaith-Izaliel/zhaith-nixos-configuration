{
  config,
  lib,
  pkgs,
  extra-types,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types optionals concatStringsSep;
  cfg = config.hellebore.shell;
  theme = config.hellebore.theme.themes.${cfg.theme};
in {
  imports = [
    ./emulator.nix
    ./prompt.nix
    ./workspace.nix
  ];

  options.hellebore.shell = {
    enable = mkEnableOption "Hellebore Shell configuration";

    theme = extra-types.theme.name {
      default = config.hellebore.theme.name;
      description = "Defines the theme used to pull some colors from to various
      aspect of the shell (Autosuggestions highlights, etc.).";
    };

    dirHashes = mkOption {
      type = types.attrs;
      default = {
        dev = "$HOME/Development";
        templates = "$HOME/Templates";
        documents = "$HOME/Documents";
        pictures = "$HOME/Pictures";
        music = "$HOME/Music";
        downloads = "$HOME/Downloads";
        notes = "$HOME/Notes";
      };
      description = "Set ZSH custom directory hashes.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      any-nix-shell
    ];

    programs = {
      command-not-found.enable = true;

      zoxide = {
        enable = true;
        enableZshIntegration = true;
      };

      zsh = {
        enable = true;
        autosuggestion.enable = true;
        enableCompletion = true;
        syntaxHighlighting.enable = true;

        shellAliases = {
          ls = "ls --color=auto";
          ll = "ls --color=auto -lh";
          grep = "grep --color=auto";
          ip = "ip --color=auto";
        };

        inherit (cfg) dirHashes;

        envExtra = concatStringsSep "\n" [
          ''
            # Vi mode
            export VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
            export VI_MODE_SET_CURSOR=true
          ''

          ''
            # Zsh autosuggestions
            export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=${theme.shell.autosuggestions}"
          ''
        ];

        initExtra = concatStringsSep "\n" [
          ''
            # Nix shell integration
            ${lib.getExe pkgs.any-nix-shell} zsh | source /dev/stdin
          ''
        ];

        oh-my-zsh = {
          enable = true;

          plugins =
            [
              "vi-mode"
              "colored-man-pages"
              "command-not-found"
            ]
            ++ (optionals config.hellebore.development.git.enable [
              "git"
              "git-flow-avh"
            ]);
        };
      };
    };
  };
}
