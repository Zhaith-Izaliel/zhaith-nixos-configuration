{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) optional types mkEnableOption mkOption mkIf optionals mkPackageOption optionalString;
  cfg = config.hellebore.games;

  nvidia-command =
    optionalString config.hardware.nvidia.prime.offload.enableOffloadCmd
    ''DXVK_FILTER_DEVICE_NAME="${config.hellebore.hardware.nvidia.deviceFilterName}" nvidia-offload'';

  gamemode-command = optionalString cfg.gamemode.enable "gamemoderun";

  game-run-script = pkgs.writeShellScriptBin "game-run" ''
    ${nvidia-command} ${gamemode-command} "''${@}"
  '';

  gamescope = {
    args =
      [
        "--fullscreen"
        "--rt"
        "--nested-refresh ${toString gameMonitor.refreshRate}"
        "-W ${toString gameMonitor.width}"
        "-H ${toString gameMonitor.height}"
        "-w ${toString gameMonitor.width}"
        "-h ${toString gameMonitor.height}"
      ]
      ++ optional config.programs.hyprland.enable "--expose-wayland"
      ++ cfg.gamescope.extraArgs;

    env =
      {
        # SDL_VIDEODRIVER = "wayland";
        XKB_DEFAULT_LAYOUT = config.hellebore.locale.keyboard.layout;
        XKB_DEFAULT_VARIANT = config.hellebore.locale.keyboard.variant;
      }
      // cfg.gamescope.extraEnv;
  };

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

  steamPackage = pkgs.steam.override {
    extraPkgs = pkgs: (with pkgs;
      [
        libgdiplus
        glib
        gvfs
        dconf
      ]
      ++ optional cfg.gamemode.enable gamemode
      ++ optionals cfg.gamescope.enable gamescope-dependencies);
  };
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
    };

    lutris = {
      enable = mkEnableOption "Lutris";

      package = mkPackageOption pkgs "lutris" {};
    };

    gamescope = {
      enable =
        mkEnableOption "Gamescope, through `steam-gamescope` and its own Display-Manager session";

      package = mkPackageOption pkgs "gamescope" {};

      capSysNice =
        mkEnableOption null
        // {
          description = "Add cap_sys_nice capability to the GameScope binary so that it may renice itself.";
        };

      extraArgs = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [];
        description = ''
          The list of Gamescope's arguments added to the default ones.
        '';
      };

      extraEnv = mkOption {
        type = types.attrsOf types.nonEmptyStr;
        default = {};
        description = ''
          An attributes set containing the environment variables used in Gamescope. These take precedence to the default ones.
        '';
      };
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
        assertion = config.hellebore.graphics.enable;
        message = "You need to enable OpenGl to run games.";
      }
    ];

    programs = {
      gamescope = {
        inherit (cfg.gamescope) enable package capSysNice;
      };

      steam = {
        inherit (cfg.steam) enable package;

        gamescopeSession = {
          inherit (cfg.gamescope) enable;
          inherit (gamescope) env args;
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
        game-run-script
      ]
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
