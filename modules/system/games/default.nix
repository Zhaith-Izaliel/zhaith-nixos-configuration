{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) optional mkEnableOption mkIf optionals mkPackageOption optionalString;
  cfg = config.hellebore.games;

  nvidia-command =
    optionalString config.hardware.nvidia.prime.offload.enableOffloadCmd
    ''DXVK_FILTER_DEVICE_NAME="${config.hellebore.hardware.nvidia.proprietary.deviceFilterName}" nvidia-offload'';

  gamemode-command = optionalString cfg.gamemode.enable "gamemoderun";

  game-run-script = pkgs.writeShellScriptBin "game-run" ''
    ${nvidia-command} ${gamemode-command} "''${@}"
  '';
in {
  imports = [
    ./gamescope.nix
  ];

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

      package = mkPackageOption pkgs "steam" {};
    };

    lutris = {
      enable = mkEnableOption "Lutris";

      package = mkPackageOption pkgs "lutris" {};
    };

    cartridges = {
      enable = mkEnableOption "Cartridges, an unified game launcher";

      package = mkPackageOption pkgs "cartridges" {};
    };

    heroic-launcher = {
      enable = mkEnableOption "Heroic Launcher, a Native GOG, Epic, and Amazon Games Launcher for Linux, Windows and Mac";

      package = mkPackageOption pkgs "heroic" {};
    };

    gamemode = {
      enable = mkEnableOption "Feral's Gamemode";

      settings = lib.mkOption {
        type = (pkgs.formats.ini {}).type;
        default = {};
        description = ''
          System-wide configuration for GameMode (/etc/gamemode.ini).
          See gamemoded(8) man page for available settings.

          This takes precedence over the default settings defined by the module.
        '';
        example = lib.literalExpression ''
          {
            general = {
              renice = 10;
            };

            # Warning: GPU optimisations have the potential to damage hardware
            gpu = {
              apply_gpu_optimisations = "accept-responsibility";
              gpu_device = 0;
              amd_performance_level = "high";
            };

            custom = {
              start = "''${pkgs.libnotify}/bin/notify-send 'GameMode started'";
              end = "''${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
            };
          }
        '';
      };

      enableRenice =
        lib.mkEnableOption "CAP_SYS_NICE on gamemoded to support lowering process niceness"
        // {
          default = true;
        };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.hellebore.graphics.enable;
        message = "You need to enable OpenGl to run games.";
      }
    ];

    programs = {
      steam = {
        inherit (cfg.steam) enable package;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };

      gamemode = {
        inherit (cfg.gamemode) enable enableRenice;

        settings =
          {
            general = {
              renice = 10;
              inhibit_screensaver = 1;
              reaper_freq = 5;
              igpu_desiredgov = "powersave";
            };
          }
          // cfg.gamemode.settings;
      };
    };

    environment.systemPackages = with pkgs;
      [
        wineWowPackages.stable
        wineWowPackages.unstableFull
        winetricks
        game-run-script
      ]
      ++ optional cfg.steam.enable protontricks
      ++ optional cfg.heroic-launcher.enable cfg.heroic-launcher.package
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
