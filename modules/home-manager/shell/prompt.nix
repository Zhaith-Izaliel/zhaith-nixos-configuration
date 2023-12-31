{ config, lib, pkgs, theme, ... }:

with lib;

let
  cfg = config.hellebore.shell.prompt;
  gitMetricsSegmentBg = "black";
  nixShellSegmentColor = theme.colors.blue;
  nixShellTextColor = theme.colors.base;
in
{
  options.hellebore.shell.prompt = {
    enable = mkEnableOption "Starship Hellebore's config";

    package = mkOption {
      type = types.package;
      default = pkgs.starship;
      description = "Override default Starship package.";
    };
  };

  config = mkIf cfg.enable {

    programs.starship = {
      enable = true;

      package = cfg.package;

      settings = {
        palette = theme.starship.paletteName;

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
          style = "bold bg:${nixShellSegmentColor} fg:${nixShellTextColor }";
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
      } // theme.starship.palette;
    };
  };
}

