{ osConfig, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.multimedia.games;
in
{
  options.hellebore.multimedia.games = {
    enable = mkEnableOption "Hellebore's games support";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> osConfig.hardware.opengl.enable &&
        osConfig.hardware.opengl.driSupport &&
        osConfig.hardware.opengl.driSupport32Bit;
        message = "You need to enable OpenGl with DRI Support (both 64 and 32
        bits) to run games.";
      }
    ];

    programs.steam.enable = true;
    home.packages = with pkgs; [
      lutris
      wineWowPackages.stable
      wine
      (wine.override { wineBuild = "wine64"; })
      wineWowPackages.staging
      winetricks
    ] ++ lists.optional config.wayland.windowManager.hyprland.enable
    wineWowPackages.waylandFull;
  };
}

