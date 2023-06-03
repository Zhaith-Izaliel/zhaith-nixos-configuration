{ config, pkgs, lib, ... }:

let
  gitMetricsSegmentBg = "black";
  nixShellSegmentColor = "#718cc6";
  catppuccin_flavour = "macchiato";
  catppuccin_palette = builtins.fromTOML (builtins.readFile
  (pkgs.fetchFromGitHub
  {
    owner = "catppuccin";
    repo = "starship";
    rev = "3e3e544"; # Replace with the latest commit hash
    sha256 = "sha256-soEBVlq3ULeiZFAdQYMRFuswIIhI9bclIU8WXjxd7oY=";
  } + /palettes/${catppuccin_flavour}.toml));
in
  {
    home.packages = with pkgs; [
      chroma
      bat
      any-nix-shell
      fzf
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
          # Colorize
          export ZSH_COLORIZE_TOOL=chroma
          export ZSH_COLORIZE_CHROMA_FORMATTER=true-color

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
          any-nix-shell zsh | source /dev/stdin

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
            "colorize"
            "command-not-found"
          ];
        };
      };

      starship = {
        enable = true;

        settings = {
          palette = "catppuccin_${catppuccin_flavour}";

        # Get editor completions based on the config schema
        "$schema" = "https://starship.rs/config-schema.json";

        continuation_prompt = "[∙](bright-black) ";

        right_format = lib.concatStrings [
          "[](fg:${gitMetricsSegmentBg})"
          "$git_metrics"
          "[▓▒░](${gitMetricsSegmentBg})"
        ];

        format = lib.concatStrings [
          "$nix_shell"
          "$username"
          "$hostname"
          "$directory"

          # "On"/"Via" modules
          "$git_branch"
          "$git_commit"
          "$git_state"
          "$git_status"
          "$docker_context"
          "$c"
          "$cmake"
          "$dotnet"
          "$golang"
          "$haskell"
          "$deno"
          "$nodejs"
          "$rust"
          "$memory_usage"
          "$sudo"
          "$cmd_duration"
          "$line_break"
          "$shell"
          "$character"
        ];

        # Inserts a blank line between shell prompts
        add_newline = true;

        git_metrics = {
          disabled = false;
          format = "[ ](bold bg:${gitMetricsSegmentBg})[+$added]($added_style)[ ▏](bg:${gitMetricsSegmentBg})[-$deleted ]($deleted_style)";
          added_style = "bold fg:green bg:${gitMetricsSegmentBg}";
          deleted_style = "bold fg:red bg:${gitMetricsSegmentBg}";
        };

        hostname = {
          style = "bold green";
          format = "[$ssh_symbol$hostname]($style) in ";
        };

        username = {
          format = "[$user]($style) @ ";
          style_user = "bold blue";
        };

        nix_shell = {
          format = "[ $symbol](bold $style)[$name]($style)[](${nixShellSegmentColor}) ";
          symbol = " ";
          style = "bg:${nixShellSegmentColor}";
        };

        c = {
          symbol = " ";
          detect_extensions = [
            "c"
            "h"
            "cpp"
            "hxx"
            "cxx"
            "hpp"
          ];
          detect_files = [
            "CMakeLists.txt"
            "CMakeCache.txt"
          ];
        };

        directory.substitutions = {
          Work = " Work";
          Companies = " Companies";
          Development = " Development";
          Templates = " Templates";
          Documents = " Documents";
          Pictures = " Pictures";
          Music = " Music";
          Downloads = " Downloads";
          Notes = "󰂺 Notes";
        };

        haskell = {
          symbol = " ";
        };

        cmake = {
          symbol = " ";
          format = "via [$symbol($version(-cmake) )]($style)";
        };

        golang = {
          symbol = " ";
        };

        nodejs = {
          symbol = " ";
        };
      } // catppuccin_palette;
    };
  };
}

