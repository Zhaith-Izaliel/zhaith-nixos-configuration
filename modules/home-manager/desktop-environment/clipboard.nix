{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf optional;
  cfg = config.hellebore.desktop-environment.clipboard;
in {
  options.hellebore.desktop-environment.clipboard = {
    enable = mkEnableOption "Hellebore's clipboard manager";
  };

  config = mkIf cfg.enable {
    home.packages = optional config.wayland.windowManager.hyprland.enable pkgs.wl-clipboard;

    services.copyq.enable = true;
  };
}
