{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.tools.discord;
in
{
  options.hellebore.tools.discord = {
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
    home.packages = [ cfg.package ]
    ++ (lists.optional cfg.betterdiscord.enable cfg.betterdiscord.package);
  };
}

