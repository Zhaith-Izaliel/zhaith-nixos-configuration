{ config, lib, pkgs, ... }:

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
        assertion = cfg.enable -> config.hardware.opengl.enable &&
        config.hardware.opengl.driSupport &&
        config.hardware.opengl.driSupport32Bit;
        message = "You need to enable OpenGl with DRI Support (both 64 and 32
        bits) to run games.";
      }
    ];

    programs.steam.enable = true;
    system.environmentPackages = with pkgs; [
      lutris
      wineWowPackages.stable
      wine
      (wine.override { wineBuild = "wine64"; })
      wineWowPackages.staging
      winetricks
    ] ++ lists.optional config.programs.hyprland.enable
    wineWowPackages.waylandFull;
  };
}

