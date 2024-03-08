{
  config,
  extra-types,
  os-config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hellebore.locale;
in {
  options.hellebore.locale = {
    enable = mkEnableOption "Hellebore locales configuration";

    keyboard = extra-types.keyboard {
      inherit (os-config.hellebore.locale.keyboard) layout variant;
    };
  };

  config = mkIf cfg.enable {
    environment.variables = {
      XKB_DEFAULT_LAYOUT = cfg.keyboard.layout;
      XKB_DEFAULT_VARIANT = cfg.keyboard.variant;
    };
  };
}
