{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkPackageOption;
  cfg = config.hellebore.desktop-environment.clipboard;
in {
  options.hellebore.desktop-environment.clipboard = {
    enable = mkEnableOption "Hellebore's clipboard manager";

    package = mkPackageOption pkgs "copyq" {};
  };

  config = mkIf cfg.enable {
    services.copyq = {
      inherit (cfg) package;
      enable = true;
    };

    home.packages = with pkgs; [
      wl-clipboard
    ];
  };
}
