{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) optional types mkEnableOption mkOption mkIf mkPackageOption concatStringsSep;
  cfg = config.hellebore.games.gamescope;

  steam-gamescope = let
    exports = builtins.attrValues (builtins.mapAttrs (n: v: "export ${n}=${v}") gamescopeEnvAndArgs.env);
  in
    pkgs.writeShellScriptBin "steam-gamescope" ''
      ${builtins.concatStringsSep "\n" exports}
      gamescope --steam ${concatStringsSep " " gamescopeEnvAndArgs.args} -- steam ${concatStringsSep " " gamescopeEnvAndArgs.steamArgs}
    '';

  gamescopeSessionFile =
    (pkgs.writeTextDir "share/wayland-sessions/steam.desktop" ''
      [Desktop Entry]
      Name=Steam
      Comment=A digital distribution platform
      Exec=${steam-gamescope}/bin/steam-gamescope
      Type=Application
    '')
    .overrideAttrs (_: {passthru.providedSessions = ["steam"];});

  gamescopeEnvAndArgs = {
    args =
      [
        "--fullscreen"
        "--nested-refresh ${toString gameMonitor.refreshRate}"
        "--generate-drm-mode fixed"
        "--hdr-enabled"
        "--backend sdl"
        # "-W ${toString gameMonitor.width}"
        # "-H ${toString gameMonitor.height}"
        "-w ${toString gameMonitor.width}"
        "-h ${toString gameMonitor.height}"
        "--steam"
      ]
      ++ optional config.programs.hyprland.enable "--expose-wayland"
      ++ cfg.extraArgs;

    steamArgs =
      [
        "-tenfoot"
        # "-pipewire-dmabuf"
      ]
      ++ cfg.extraSteamArgs;

    env =
      {
        XKB_DEFAULT_LAYOUT = config.hellebore.locale.keyboard.layout;
        XKB_DEFAULT_VARIANT = config.hellebore.locale.keyboard.variant;

        # This should be used by default by gamescope. Cannot hurt to force it anyway.
        ENABLE_GAMESCOPE_WSI = "1";

        # Force Qt applications to run under xwayland
        QT_QPA_PLATFORM = "xcb";

        # Used with --backend sdl to allow clipboard synchronisation
        SDL_VIDEODRIVER = "wayland";

        # Window managers sets this to wayland but apps using Gamescope must use x11
        XDG_SESSION_TYPE = "x11";

        # Some environment variables by default (taken from Deck session)
        SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "0";

        # Don't wait for buffers to idle on the client side before sending them to gamescope
        vk_xwayland_wait_ready = "false";

        # To expose vram info from radv
        WINEDLLOVERRIDES = "dxgi=n";

        # Workaround older versions of vkd3d-proton setting this
        # too low (desc.BufferCount), resulting in symptoms that are potentially like
        # swapchain starvation.
        VKD3D_SWAPCHAIN_LATENCY_FRAMES = "3";

        # There is no way to set a color space for an NV12
        # buffer in Wayland. And the color management protocol that is
        # meant to let this happen is missing the color range...
        # So just workaround this with an ENV var that Remote Play Together
        # and Gamescope will use for now.
        GAMESCOPE_NV12_COLORSPACE = "k_EStreamColorspace_BT601";

        # Temporary crutch until dummy plane interactions / etc are figured out
        GAMESCOPE_DISABLE_ASYNC_FLIPS = "1";

        # To play nice with the short term callback-based limiter for now
        GAMESCOPE_LIMITER_FILE = "$(mktemp /tmp/gamescope-limiter.XXXXXXXX)";
      }
      // cfg.extraEnv;
  };

  gameMonitor = builtins.elemAt config.hellebore.monitors cfg.monitorID;
in {
  options.hellebore.games.gamescope = {
    enable = mkEnableOption "Gamescope, through `steam-gamescope` and its own Display-Manager session";

    session = mkEnableOption "Gamescope's own Display-Manager session";

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

    extraSteamArgs = mkOption {
      type = types.listOf types.nonEmptyStr;
      default = [];
      description = ''
        The list of Steam's arguments added to the default ones.
      '';
    };

    extraEnv = mkOption {
      type = types.attrsOf types.nonEmptyStr;
      default = {};
      description = ''
        An attributes set containing the environment variables used in Gamescope. These take precedence to the default ones.
      '';
    };

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
        message = "You need to enable OpenGl to run gamescope.";
      }
    ];

    environment.systemPackages = [
      steam-gamescope
    ];

    programs.steam.gamescopeSession.enable = true;

    hardware.pulseaudio.support32Bit = config.hardware.pulseaudio.enable;

    security.wrappers = lib.mkIf (cfg.enable && cfg.capSysNice) {
      # needed or steam fails
      bwrap = {
        owner = "root";
        group = "root";
        source = "${pkgs.bubblewrap}/bin/bwrap";
        setuid = true;
      };
    };

    programs.gamescope = {
      inherit (cfg) package capSysNice;
      enable = true;
    };

    services.displayManager.sessionPackages = lib.mkIf cfg.session [gamescopeSessionFile];
  };
}
