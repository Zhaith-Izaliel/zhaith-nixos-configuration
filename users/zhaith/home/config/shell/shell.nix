{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    any-nix-shell
  ];

  programs = {
    # Command not found for ZSH
    command-not-found.enable = true;

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true;

      shellAliases = {
        ls = "ls --color=auto";
        ll = "ls --color=auto -lh";
        grep = "grep --color=auto";
        ip = "ip --color=auto";
        cat = "ccat";
        less = "cless";
        ssh = "kitty +kitten ssh";
        icat = "kitty +kitten icat";
      };

      dirHashes = {
        dev = "$HOME/Development";
        templates = "$HOME/Templates";
        documents = "$HOME/Documents";
        pictures = "$HOME/Pictures";
        music = "$HOME/Music";
        downloads = "$HOME/Downloads";
        notes = "$HOME/Notes";
      };

      envExtra = ''
      # Language
      export LANG="en_US.UTF-8"

      # EDITOR and VISUAL
      export VISUAL="nvim"
      export EDITOR="nvim"

      # Remove log from direnv
      export DIRENV_LOG_FORMAT=""

      # Zsh autosuggestions
      export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#a5adcb"
      '';

      initExtra = ''
      # Neofetch MOTD
      export NEOFETCH_IMAGE="/home/zhaith/Pictures/Wallpapers/Nord/cats.png"

      if [ "$KITTY_WINDOW_ID" = "1" ]; then
        neofetch --kitty $NEOFETCH_IMAGE
      fi

      # Nix shell integration
      ${pkgs.any-nix-shell}/bin/any-nix-shell zsh | source /dev/stdin

      # Auto use direnv
      eval "$(direnv hook zsh)"
      '';

      oh-my-zsh = {
        enable = true;

        plugins = [
          "vi-mode"
          "git"
          "git-flow-avh"
          "colored-man-pages"
          "command-not-found"
        ];
      };
    };
  };
}

