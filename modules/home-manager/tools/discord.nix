{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.discord;
in
{
  options.hellebore.discord = {
    enable = mkEnableOption "discord Hellebore's config";

    package = mkOption {
      type = types.package;
      default = pkgs.discord-ptb;
      description = "The default Discord package.";
    };

    betterdiscord = {
      enable = mkEnableOption "betterdiscordctl";

      package = mkOption {
        type = types.package;
        default = pkgs.betterdiscordctl;
        description = "The default BetterDiscord package.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = cfg.package ++ (if cfg.betterdiscord.enable then
    cfg.betterdiscord.package else []);
  };
}

