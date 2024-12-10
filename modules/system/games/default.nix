{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    optional
    mkEnableOption
    mkIf
    optionals
    mkPackageOption
    optionalString
    types
    mkOption
    mkMerge
    recursiveUpdate
    ;

  cfg = config.hellebore.games;

  nvidia-command =
    optionalString config.hardware.nvidia.prime.offload.enableOffloadCmd
    ''DXVK_FILTER_DEVICE_NAME="${config.hellebore.hardware.nvidia.proprietary.deviceFilterName}" nvidia-offload'';

  gamemode-command = optionalString cfg.gamemode.enable "gamemoderun";

  game-run-script = pkgs.writeShellScriptBin "game-run" ''
    ${nvidia-command} ${gamemode-command} "''${@}"
  '';

  enabled = builtins.any (item: item) [
    cfg.cartridges.enable
    cfg.game-run.enable
    cfg.gamemode.enable
    cfg.heroic-launcher.enable
    cfg.minecraft.enable
    cfg.moonlight.enable
    cfg.steam.enable
    cfg.umu.enable
    cfg.wine.enable
  ];
in {
  imports = [
    ./gamescope.nix
  ];

  options.hellebore.games = {
    enabled = mkOption {
      type = types.bool;
      default = enabled || cfg.gamescope.enable;
      description = "Defines if one of these submodules are enabled.";
      readOnly = true;
    };

    game-run = {
      enable = mkEnableOption "Game-Run wrapper script";
    };

    wine = {
      enable = mkEnableOption "Windows game support through WINE. It is required for Steam";

      extraPackages = mkOption {
        type = types.listOf types.package;
        default = [];
        description = "Extra WINE packages to install.";
      };
    };

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

    umu = {
      enable = mkEnableOption "UMU, the unified launcher for Windows games on Linux";

      package = mkPackageOption pkgs "umu" {};
    };

    moonlight = {
      enable = mkEnableOption "Moonlight, a GameStream client for PCs.";

      package = mkPackageOption pkgs "moonlight-qt" {};
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

  config = mkIf enabled (mkMerge [
    {
      assertions = [
        {
          assertion = config.hellebore.graphics.enable;
          message = "You need to enable OpenGl to run games.";
        }
      ];
    }

    (mkIf cfg.steam.enable {
      programs.steam = {
        inherit (cfg.steam) package;
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };

      environment.systemPackages = with pkgs; [
        protontricks
      ];
    })

    (mkIf cfg.gamemode.enable {
      programs.gamemode = {
        inherit (cfg.gamemode) enableRenice;
        enable = true;

        settings =
          recursiveUpdate {
            general = {
              renice = 10;
              inhibit_screensaver = 1;
              reaper_freq = 5;
              igpu_desiredgov = "powersave";
            };
          }
          cfg.gamemode.settings;
      };
    })

    (mkIf cfg.wine.enable {
      environment.systemPackages =
        (with pkgs; [
          wineWowPackages.stable
          wineWowPackages.unstableFull
          winetricks
        ])
        ++ cfg.wine.extraPackages;
    })

    {
      environment.systemPackages =
        optional cfg.game-run.enable game-run-script
        ++ optional cfg.heroic-launcher.enable cfg.heroic-launcher.package
        ++ optional cfg.cartridges.enable cfg.cartridges.package
        ++ optionals cfg.lutris.enable [
          cfg.lutris.package
          pkgs.dxvk
        ]
        ++ optional cfg.minecraft.enable cfg.minecraft.package
        ++ optional cfg.minecraft.mods.enable cfg.minecraft.mods.package
        ++ optional cfg.umu.enable cfg.umu.package
        ++ optional cfg.moonlight.enable cfg.moonlight.package;
    }
  ]);
}
