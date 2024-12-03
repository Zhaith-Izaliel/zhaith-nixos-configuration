{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkPackageOption mkEnableOption mkOption types;
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
  cfg = config.hellebore.development.erdtree;
in {
  options.hellebore.development.erdtree = {
    enable = mkEnableOption "Erdtree - A modern, cross-platform, multi-threaded,
    and general purpose filesystem and disk-usage utility that is aware of
    .gitignore and hidden file rules";

    package = mkPackageOption pkgs "erdtree" {};

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
    home.packages = [cfg.package];
    xdg.configHome."erdtree/.erdtreerc".text = cfg.settings;
  };
}
