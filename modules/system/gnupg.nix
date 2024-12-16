{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkPackageOption;
  cfg = config.hellebore.gnupg;
in {
  options.hellebore.gnupg = {
    enable = mkEnableOption "GNUPG system-wide SSH agent";

    package = mkPackageOption pkgs "gnupg" {};
  };

  config = mkIf cfg.enable {
    programs.gnupg = {
      inherit (cfg) package;

      agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };
  };
}
