{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) optionalString concatStringsSep optional types mkEnableOption mkOption mkIf optionals mdDoc mkPackageOption;
  cfg = config.hellebore.games;

  nvidia-command = optionalString config.hardware.nvidia.prime.offload.enableOffloadCmd ''DXVK_FILTER_DEVICE_NAME="${config.hellebore.hardware.nvidia.deviceFilterName}" nvidia-offload'';

  game-run-script = pkgs.writeShellScriptBin "game-run" ''
    #!/usr/bin/env bash
    export XKB_DEFAULT_LAYOUT="${config.hellebore.locale.keyboard.layout}"
    export XKB_DEFAULT_VARIANT="${config.hellebore.locale.keyboard.variant}"

    main() {
      case "$1" in
        --gamescope)
          ${nvidia-command} gamemoderun gamescope ${concatStringsSep " " gamescope-args} "''${@:2}"
        ;;

        *)
          ${nvidia-command} gamemoderun "$@"
        ;;
      esac
    }

    main "$@"
  '';

  gamescope-args =
    optional config.programs.hyprland.enable "--expose-wayland"
    ++ [
      "-f"
      "--adaptive-sync"
      "--force-composition"
      "-W ${toString gameMonitor.width}"
      "-H ${toString gameMonitor.height}"
      "-w ${toString gameMonitor.width}"
      "-h ${toString gameMonitor.height}"
    ];

  gameMonitor = builtins.elemAt config.hellebore.monitors cfg.monitorID;

  steamPackage = pkgs.steam.override ({extraPkgs ? pkgs': [], ...}: {
    extraPkgs = pkgs':
      (extraPkgs pkgs')
      ++ (with pkgs';
        [
          libgdiplus
          glib
          gvfs
          dconf
        ]
        ++ optional cfg.gamemode.enable gamemode
        ++ optionals cfg.gamescope.enable [
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
in {
  options.hellebore.games = {
    enable = mkEnableOption "Hellebore's games support";

    minecraft = {
      enable = mkEnableOption "Minecraft Prismlauncher";

      package = mkPackageOption pkgs "prismlauncher" {};
    };

    steam = {
      enable = mkEnableOption "Steam";

      package = mkOption {
        type = types.package;
        default = steamPackage;
        description = "The steam package to use.";
      };

      gamescope.session = {
        enable = mkEnableOption "Gamescope standalone session";
        args =
          mkOption {
            type = types.listOf types.str;
            default = [];
            description = "List of arguments used when running the gamescope
        session.";
          };
        env = mkOption {
          type = types.attrsOf types.str;
          default = {};
          description = mdDoc ''
            Environmental variables to be passed to GameScope for the session.
          '';
        };
      };
    };

    lutris = {
      enable = mkEnableOption "Lutris";

      package = mkPackageOption pkgs "lutris" {};
    };

    gamescope = {
      enable = mkEnableOption "Lutris";

      package = mkPackageOption pkgs "gamescope" {};
    };

    cartridges = {
      enable = mkEnableOption "Cartridges, an unified game launcher";

      package = mkPackageOption pkgs "cartridges" {};
    };

    gamemode.enable = mkEnableOption "Feral's Gamemode";

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
        assertion =
          cfg.enable
          -> config.hardware.opengl.enable
          && config.hardware.opengl.driSupport
          && config.hardware.opengl.driSupport32Bit;
        message = "You need to enable OpenGl with DRI Support (both 64 and 32
        bits) to run games.";
      }
    ];

    programs = {
      gamescope = {
        inherit (cfg.gamescope) enable package;
      };

      steam = {
        inherit (cfg.steam) enable package;

        gamescopeSession = {
          inherit (cfg.steam.gamescope.session) enable args env;
        };
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };

      gamemode = {
        inherit (cfg.gamemode) enable;

        settings = {
          general = {
            renice = 10;
            inhibit_screensaver = 1;
            reaper_freq = 5;
            igpu_desiredgov = "powersave";
          };
        };
      };
    };

    environment.systemPackages = with pkgs;
      [
        protontricks
        wineWowPackages.stable
        heroic
        wine
        (wine.override {wineBuild = "wine64";})
        wineWowPackages.staging
        winetricks
        game-run-script
      ]
      ++ optional cfg.cartridges.enable cfg.cartridges.package
      ++ optionals cfg.lutris.enable [
        cfg.lutris.package
        dxvk
      ]
      ++ optionals config.programs.hyprland.enable
      [
        winePackages.waylandFull
        wine64Packages.waylandFull
        wine-wayland
      ]
      ++ optional cfg.minecraft.enable cfg.minecraft.package;
  };
}
