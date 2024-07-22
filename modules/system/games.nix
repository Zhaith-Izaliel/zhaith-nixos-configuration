{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) concatStringsSep optional types mkEnableOption mkOption mkIf optionals mdDoc mkPackageOption optionalString;
  cfg = config.hellebore.games;

  nvidia-command =
    optionalString config.hardware.nvidia.prime.offload.enableOffloadCmd
    ''DXVK_FILTER_DEVICE_NAME="${config.hellebore.hardware.nvidia.deviceFilterName}" nvidia-offload'';

  gamemode-command = optionalString cfg.gamemode.enable "gamemoderun";

  gamescope-command = optionalString cfg.gamescope.enable "gamescope ${concatStringsSep " " gamescope-args} --";

  game-run-script = pkgs.writeShellScriptBin "game-run" ''
    main() {
      case "$1" in
      --gamescope)
        ${gamescope-command} ${gamemode-command} "''${@:2}"
      ;;

      *)
      ${nvidia-command} ${gamemode-command} "''${@}"
      ;;
      esac
    }

    main "$@"
  '';

  gamescope-args =
    optional config.programs.hyprland.enable "--expose-wayland"
    ++ [
      "-f"
      # "--adaptive-sync"
      "-W ${toString gameMonitor.width}"
      "-H ${toString gameMonitor.height}"
      "-w ${toString gameMonitor.width}"
      "-h ${toString gameMonitor.height}"
    ];

  gameMonitor = builtins.elemAt config.hellebore.monitors cfg.monitorID;

  gamescope-dependencies = with pkgs; [
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
  ];

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
        ++ optionals cfg.gamescope.enable gamescope-dependencies);
  });
in {
  options.hellebore.games = {
    enable = mkEnableOption "Hellebore's games support";

    minecraft = {
      enable = mkEnableOption "Minecraft Prismlauncher";

      package = mkPackageOption pkgs "prismlauncher" {};

      mods = {
        enable = mkEnableOption "Minecraft mods support through Ferium";

        package = mkPackageOption pkgs "ferium" {};
      };
    };

    steam = {
      enable = mkEnableOption "Steam";

      package =
        mkPackageOption pkgs "steam" {}
        // {
          default = steamPackage;
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
      enable =
        mkEnableOption "Gamescope"
        // {
          default = true;
        };

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
        assertion = config.hardware.opengl.enable && config.hardware.opengl.driSupport32Bit && config.hardware.opengl.driSupport;
        message = "You need to enable OpenGl to run games.";
      }
    ];

    programs = {
      gamescope = {
        inherit (cfg.gamescope) enable package;

        env = {
          SDL_VIDEODRIVER = "wayland";
          XKB_DEFAULT_LAYOUT = config.hellebore.locale.keyboard.layout;
          XKB_DEFAULT_VARIANT = config.hellebore.locale.keyboard.variant;
        };
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
        wineWowPackages.unstableFull
        winetricks
      ]
      ++ optional cfg.gamescope.enable game-run-script
      ++ optional cfg.cartridges.enable cfg.cartridges.package
      ++ optionals cfg.lutris.enable [
        cfg.lutris.package
        dxvk
      ]
      ++ optionals cfg.minecraft.enable
      [
        cfg.minecraft.package
      ]
      ++ optional cfg.minecraft.mods.enable cfg.minecraft.mods.package;
  };
}
