{ config, lib, pkgs, ...}:

with lib;

let
  erdConfig = ''
    # Human readable sizes
    --human

    # Inverted tree
    --layout inverted

    # Using Icons
    --icons

    # Sort
    --dir-order first
    --sort name
    '';
    cfg = config.hellebore.erdtree;
in
{
  options.hellebore.erdtree = {
    enable = mkEnableOption "Erdtree - A modern, cross-platform, multi-threaded,
    and general purpose filesystem and disk-usage utility that is aware of
    .gitignore and hidden file rules";

    package = mkOption {
      type = types.package;
      default = pkgs.erdtree;
      defaultText = literalExpression "pkgs.erdtree";
      description = "Erdtree package to install";
    };

    settings = mkOption {
      type = types.str;
      default = erdConfig;
      example = ''
        --human
        --layout inverted
      '';
      description = "Override Hellebore's Erdtree configuration options.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    home.file."${config.xdg.configHome}/erdtree/.erdtreerc".text = cfg.settings;
  };
}

