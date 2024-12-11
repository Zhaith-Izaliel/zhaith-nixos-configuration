{
  os-config,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkPackageOption;
  cfg = config.hellebore.desktop-environment.mail;
in {
  options.hellebore.desktop-environment.mail = {
    enable = mkEnableOption "Hellebore's mail configuration";

    package = mkPackageOption pkgs "thunderbird-bin" {};
  };

  config = mkIf cfg.enable {
    programs.thunderbird = {
      inherit (cfg) package;
      enable = true;
      profiles."zhaith".isDefault = true;
    };
  };
}
