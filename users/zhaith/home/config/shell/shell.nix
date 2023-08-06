{ pkgs, theme, lib, ... }:

let
  image = lib.cleanSource ../../../../../assets/images/neofetch/neofetch.png;
in
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
        ssh = "kitty_ssh";
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
      if [ "$KITTY_WINDOW_ID" = "1" ]; then
        ${lib.getExe pkgs.neofetch} --kitty ${image}
      fi

      # Nix shell integration
      ${lib.getExe pkgs.any-nix-shell} zsh | source /dev/stdin

      # Auto use direnv
      eval "$(direnv hook zsh)"

      # Special functions
      kitty_ssh() {
        if [ "$TERM" = "xterm-kitty" ]; then
          ${lib.getExe pkgs.kitty} +kitten ssh $*
          return $!
        fi
        ${pkgs.openssh}/bin/ssh $*
      }
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

    starship = {
      enable = true;
      inherit (theme.starship-theme.starship) settings;
    };
  };
}

