{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.games;
  gamemode-icon = cleanSource ../../assets/images/icons/gamemode.svg;
  notify-send-gamemode = message:
    "${pkgs.libnotify}/bin/notify-send -u critical -i ${gamemode-icon} -t 4000 '${message}'";
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

    boot.kernelParams = lists.optional config.hardware.nvidia.modesetting.enable
    "nvidia-drm.modeset=1";

    programs = {
      gamescope = mkIf (!config.programs.hyprland.xwayland.enable) {
        enable = true;
        args = lists.optional config.programs.hyprland.enable "--expose-wayland";
      };

      steam = {
        enable = true;
        gamescopeSession = mkIf (!config.programs.hyprland.xwayland.enable) {
          enable = true;
          args = lists.optional config.programs.hyprland.enable "--expose-wayland";
        };
      };

      gamemode = {
        enable = true;

        settings = {
          general = {
            renice = 10;
            inhibit_screensaver = 1;
            reaper_freq = 5;
            igpu_desiredgov = "powersave";
          };

          custom = {
            start = notify-send-gamemode "GameMode started";
            end = notify-send-gamemode "GameMode stopped";
          };
        };
      };
    };

    environment.systemPackages = with pkgs; [
      lutris
      protontricks
      wineWowPackages.stable
      wine
      (wine.override { wineBuild = "wine64"; })
      wineWowPackages.staging
      winetricks
    ] ++ lists.optional config.programs.hyprland.enable
    wineWowPackages.waylandFull;
  };
}

