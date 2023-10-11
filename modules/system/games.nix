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

    programs = {
      gamescope = {
        enable = true;
        args = lists.optional config.programs.hyprland.enable "--expose-wayland";
      };

      steam = {
        enable = true;
        gamescopeSession = {
          enable = true;
          args = lists.optional config.programs.hyprland.enable "--expose-wayland";
        };
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };

      gamemode = {
        enable = true;

        settings = {
          general = {
            renice = 10;
            inhibit_screensaver = 0;
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
      steamtinkerlaunch
    ] ++ lists.optional config.programs.hyprland.enable
    wineWowPackages.waylandFull;
  };
}

