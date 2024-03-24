{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf types mkPackageOption;
  cfg = config.hellebore.development.git.h;
in {
  options.hellebore.development.git.h = {
    enable = mkEnableOption "h git utility";

    package = mkPackageOption pkgs "h" {};

    codeDirectory = mkOption {
      type = types.nonEmptyStr;
      default = config.hellebore.development.codeDirectory;
      description = "Code directory used with h.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      h
    ];

    programs.zsh.initExtra = ''
      eval "$(h --setup ${cfg.codeDirectory})"
      eval "$(up --setup)"
    '';
  };
}
