{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hellebore.shell;
in {
  options.hellebore.shell = {
    enable = mkEnableOption "Hellebore shell configuration";
  };

  config = mkIf cfg.enable {
    environment.shells = with pkgs; [zsh bash bashInteractive];
    programs.zsh.enable = true;
  };
}
