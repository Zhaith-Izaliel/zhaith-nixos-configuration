{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.games;
  gamemode-icon = cleanSource ../../assets/images/icons/gamemode.svg;
  notify-send-gamemode = message:
    "${pkgs.libnotify}/bin/notify-send -u critical -i ${gamemode-icon} -t 4000 '${message}'";

  # Gamemode Start/Stop scripts
  gamemode-start-script = pkgs.writeShellScriptBin "gamemode-start" ''
  ${notify-send-gamemode "GameMode Started"}
  '';

  gamemode-stop-script = pkgs.writeShellScriptBin "gamemode-stop" ''
  ${notify-send-gamemode "GameMode Stopped"}
  '';

  game-run-script = pkgs.writeShellScriptBin "game-run" (
    strings.concatStringsSep
    "\n"
    [
      ''
      #!/usr/bin/env bash

      gamescope_run() {
        if [ "$1" = "--steam" ]; then
          gamescope -e "$2"
        else
          gamescope "$@"
        fi
      }
      ''

      (strings.optionalString config.hardware.nvidia.prime.offload.enableOffloadCmd
      ''
      export DXVK_FILTER_DEVICE_NAME="${config.hellebore.hardware.nvidia.deviceFilterName}"
      nvidia-offload \
      '')

      ''
      gamemoderun \
      ''

      (strings.optionalString cfg.gamescope.enable
      ''
      gamescope_run \
      '')
      "$@"
    ]
  );

  gameMonitor = builtins.elem cfg.monitorID config.hellebore.monitors;
in
  {
    options.hellebore.games = {
      enable = mkEnableOption "Hellebore's games support";

      gamescope.enable = mkEnableOption "Gamescope support";

      minecraft.enable = mkEnableOption "Minecraft Prismlauncher";

      monitorID = mkOption {
        type = types.ints.unsigned;
        default = 0;
        description = "The monitor ID used for gaming. The ID corresponds to the
        index of the monitor in {option}`config.hellebore.monitors`.";
      };
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

      nixpkgs.overlays = [
        (final: prev: {
          steam = prev.steam.override ({ extraPkgs ? pkgs': [], ... }: {
            extraPkgs = pkgs': (extraPkgs pkgs') ++ (with pkgs'; [
              libgdiplus
              gamemode
              glib
              gvfs
              dconf
            ] ++ lists.optionals cfg.gamescope.enable [
              xorg.libXcursor
              xorg.libXi
              xorg.libXinerama
              xorg.libXScrnSaver
              libpng
              libpulseaudio
              libvorbis
              stdenv.cc.cc.lib
              libkrb5
              keyutils
            ]);
          });
        })
      ];

      programs = {
        gamescope = mkIf cfg.gamescope.enable {
          enable = true;
          args = lists.optional config.programs.hyprland.enable "--expose-wayland"
          ++ [
            "-f"
            "--force-grab-cursor"
            "--adaptive-sync"
            "--force-composition"
            "-W ${toString gameMonitor.width}"
            "-H ${toString gameMonitor.height}"
            "-w ${toString gameMonitor.width}"
            "-h ${toString gameMonitor.height}"
          ];
        };

        steam = {
          enable = true;
          gamescopeSession = mkIf cfg.gamescope.enable {
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
              inhibit_screensaver = 1;
              reaper_freq = 5;
              igpu_desiredgov = "powersave";
            };

            custom = {
              start = "${gamemode-start-script}";
              end = "${gamemode-stop-script}";
            };
          };
        };
      };

      environment.systemPackages = with pkgs; [
        lutris
        cartridges
        protontricks
        wineWowPackages.stable
        wine
        (wine.override { wineBuild = "wine64"; })
        wineWowPackages.staging
        winetricks
        game-run-script
      ] ++ lists.optional config.programs.hyprland.enable
      wineWowPackages.waylandFull
      ++ lists.optional cfg.minecraft.enable prismlauncher;
    };
  }

