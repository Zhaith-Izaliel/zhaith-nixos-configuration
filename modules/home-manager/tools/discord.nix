{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkEnableOption mkPackageOption mkIf types;
  cfg = config.hellebore.tools.discord;
  finalPackage = cfg.package.override {
    withTTS = cfg.tts.enable;
  };
in {
  options.hellebore.tools.discord = {
    enable = mkEnableOption "discord Hellebore's config";

    package = mkPackageOption pkgs "vesktop" {};

    finalPackage = mkOption {
      type = types.package;
      default = finalPackage;
      description = "The final built package after overrides.";
      readOnly = true;
    };

    tts.enable = mkEnableOption "TTS support";
  };

  config = mkIf cfg.enable {
    home.packages = [
      finalPackage
    ];
  };
}
