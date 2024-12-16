{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkPackageOption mkOption types;
  cfg = config.hellebore.desktop-environment.hyprland.hyprscroller;
in {
  options.hellebore.desktop-environment.hyprland.hyprscroller = {
    enable = mkEnableOption "Hyprscroller for Hyprland. Hyprland needs to be enabled for Hyprscroller to work";

    package = mkPackageOption pkgs ["hyprlandPlugins" "hyprscroller"] {};
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.wayland.windowManager.hyprland.enable;
        message = "You need to enable Hyprland for Hyprscroller to work.";
      }
    ];

    wayland.windowManager.hyprland = {
      plugins = [cfg.package];
      settings = {
      };
    };
  };
}
