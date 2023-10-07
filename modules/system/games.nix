{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.games;
in
{
  options.hellebore.games = {
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

    programs.gamescope.enable = true;

    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
    environment.systemPackages = with pkgs; [
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

