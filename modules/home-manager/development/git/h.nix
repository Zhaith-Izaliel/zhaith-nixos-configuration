{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hellebore.development.git.h;
in {
  options.hellebore.development.git.h = {
    enable = mkEnableOption "H git utility";

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
