{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.shell;
in
{
  options.hellebore.shell = {
    enable = mkEnableOption "Hellebore shell configuration";
  };

  config = mkIf cfg.enable {
    environment.shells = with pkgs; [ zsh bash bashInteractive ];
    programs.zsh.enable = true;
  };
}

