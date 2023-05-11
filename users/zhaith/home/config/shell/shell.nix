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
  git-flow-completion = pkgs.stdenv.mkDerivation rec {
    name = "git-flow-completion";
    version = "1.1.0";

    src = pkgs.fetchFromGitHub {
      owner = "bobthecow";
      repo = name;
      rev  = version;
      sha256 = "sha256-ccRJEycguVdsEXVURX74iuKPSDxOR9bdpCUn9aHcL2Y=";
    };

    installPhase = ''
      mkdir -p $out
      cp -r git.fish $out/git-flow.fish
    '';
  };
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
        enableFishIntegration = true;
      };

      # ZSH and Oh-My-ZSH
      fish = {
        enable = true;

        shellAliases = {
          ls = "ls --color=auto";
          ll = "ls --color=auto -lh";
          grep = "grep --color=auto";
          ip = "ip --color=auto";
          tree = "tree -C";
          cat = "bat";
          #ssh = "kitty +kitten ssh";
          icat = "kitty +kitten icat";
        };

        shellAbbrs = {
          companies = "$HOME/Documents/Work/Companies";
          freelance = "$HOME/Documents/Work/Freelance";
          dev = "$HOME/Development";
          templates = "$HOME/Templates";
          documents = "$HOME/Documents";
          pictures = "$HOME/Pictures";
          music = "$HOME/Music";
          downloads = "$HOME/Downloads";
          cheatsheets = "$HOME/Cheatsheets";
        };

        shellInit = ''
          # ---Exports---

          # Language
          set -xg LANG en_US.UTF-8

          # EDITOR and VISUAL
          set -xg VISUAL 'nvim'
          set -xg EDITOR 'nvim'

          # Remove log from direnv
          set -xg DIRENV_LOG_FORMAT ""

          # Remove greeting
          set fish_greeting ""

          # ---Inits---

          # Neofetch MOTD
          set -x NEOFETCH_IMAGE "/home/zhaith/Pictures/Wallpapers/Nord/cats.png"
          if test "$KITTY_WINDOW_ID" = "1"
          neofetch --kitty $NEOFETCH_IMAGE
          end

          # Nix shell integration
          any-nix-shell fish --info-right | source

          # Auto use direnv
          direnv hook fish | source

          # Set vi mode
          fish_vi_key_bindings
        '';

        plugins = [
          {
            name = "fish-git";
            src = pkgs.fetchFromGitHub {
              owner = "jhillyerd";
              repo = "plugin-git";
              rev = "1697adf";
              sha256 = "sha256-tsw+npcOga8NBM1F8hnsT69k33FS5nK1zaPB1ohasPk=";
            };
          }
          {
            name = "colored-man-page";
            src = pkgs.fishPlugins.colored-man-pages;
          }
        ];
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
          Companies = " Companies";
          Freelance = " Freelance";
          Development = " Development";
          Templates = " Templates";
          Documents = " Documents";
          Pictures = " Pictures";
          Music = " Music";
          Downloads = " Downloads";
          Cheatsheets = " Cheatsheets";
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

  # HACK: Completion for git-flow for FISH
  home.file = {
    ".config/fish/completions/git-flow.fish".source = "${git-flow-completion}/git-flow.fish";
  };
}
