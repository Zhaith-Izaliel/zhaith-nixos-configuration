{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hellebore.tools.discord;
  finalPackage = cfg.package.override {
    withOpenASAR = cfg.openASAR.enable;
    withVencord = cfg.vencord.enable;
    withTTS = cfg.tts.enable;
  };
in {
  options.hellebore.tools.discord = {
    enable = mkEnableOption "discord Hellebore's config";

    package = mkOption {
      type = types.package;
      default = pkgs.discord;
      description = "The default Discord package.";
    };

    finalPackage = mkOption {
      type = types.package;
      default = finalPackage;
      description = "The final built package after overrides.";
      readOnly = true;
    };

    betterdiscord = {
      enable = mkEnableOption "betterdiscordctl";

      package = mkOption {
        type = types.package;
        default = pkgs.betterdiscordctl;
        description = "The default BetterDiscord package.";
      };
    };

    vencord.enable = mkEnableOption "Vencord integration";

    openASAR.enable = mkEnableOption "openASAR integration";

    tts.enable = mkEnableOption "TTS support";
  };

  config = mkIf cfg.enable {
    home.packages =
      [
        finalPackage
      ]
      ++ (lists.optional cfg.betterdiscord.enable cfg.betterdiscord.package);
  };
}
