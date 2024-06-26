{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hellebore.desktop-environment.clipboard;
in {
  options.hellebore.desktop-environment.clipboard = {
    enable = mkEnableOption "Hellebore's clipboard manager";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
      cliphist
    ];
  };
}
