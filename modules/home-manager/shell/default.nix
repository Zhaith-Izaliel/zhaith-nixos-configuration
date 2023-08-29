{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.shell;
  image = lib.cleanSource cfg.motd.image;
in
{
  imports = [
    ./emulator.nix
    ./prompt.nix
  ];

  options.hellebore.shell = {
    enable = mkEnableOption "Hellebore Shell configuration";

    motd = {
      enable = mkEnableOption "Neofetch MOTD";
      image = mkOption {
        type = types.path;
        default = ../../../assets/images/neofetch/neofetch.png;
        description = "Image used with Neofetch. Can only be used if kitty is
        enabled";
      };
    };

    dirHashes = mkOption {
      type = types.attr;
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

    enableDirenvLogs = mkEnableOption "Direnv Logs when getting in a Direnv
    directory";
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
        enableAutosuggestions = true;
        enableCompletion = true;
        syntaxHighlighting.enable = true;

        shellAliases = {
          ls = "ls --color=auto";
          ll = "ls --color=auto -lh";
          grep = "grep --color=auto";
          ip = "ip --color=auto";
        } // (mkIf config.programs.kitty.enable {
          kssh = "kitty_ssh";
          icat = "kitty +kitten icat";
        });

        inherit (cfg) dirHashes;

        envExtra = ''
        # Language
        export LANG="en_US.UTF-8"

        # EDITOR and VISUAL
        export VISUAL="nvim"
        export EDITOR="nvim"

        ${strings.optional (!cfg.enableDirenvLogs)
        ''# Remove log from direnv
        export DIRENV_LOG_FORMAT=""''
        }

        # Zsh autosuggestions
        export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=${theme.colors.subtext}"
        '';

        initExtra = ''
        ${strings.optional cfg.motd.enable (if config.programs.kitty.enable then ''
          # Neofetch MOTD
          if [ "$KITTY_WINDOW_ID" = "1" ]; then
            ${lib.getExe pkgs.neofetch} --kitty ${image}
          fi
        '' else "${getExe pkgs.neofetch}")}

        # Nix shell integration
        ${lib.getExe pkgs.any-nix-shell} zsh | source /dev/stdin

        # Auto use direnv
        eval "$(direnv hook zsh)"


        # Special functions
        ${strings.optional config.programs.kitty.enable
          ''kitty_ssh() {
            if [ "$TERM" = "xterm-kitty" ]; then
              ${pkgs.kitty}/bin/kitty +kitten ssh $*
              return $!
            fi
            ${pkgs.openssh}/bin/ssh $*
          }''
        }
        '';

        oh-my-zsh = {
          enable = true;

          plugins = [
            "vi-mode"
            "colored-man-pages"
            "command-not-found"
          ] ++ (lists.optionals config.hellebore.development.git.enable [
            "git"
            "git-flow-avh"
          ]);
        };
      };
    };
  };
}

