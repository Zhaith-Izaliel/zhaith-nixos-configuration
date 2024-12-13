{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkPackageOption optionalString mkIf types concatStringsSep mkOption optionalAttrs;
  cfg = config.hellebore.hyprland;
  finalPackage = cfg.package.override {enableXWayland = true;};
in {
  options.hellebore.hyprland = {
    enable = mkEnableOption "Hellebore Hyprland configuration";

    package = mkPackageOption pkgs "hyprland" {};

    enableSwaylockPam = mkEnableOption "Swaylock PAM configuration";

    enableHyprlockPam = mkEnableOption "Hyprlock PAM configuration";

    renderingCards = mkOption {
      type = types.listOf types.nonEmptyStr;
      default = [];
      description = "Defines the cards used for rendering WLRoots based compositors, in order of priority.";
    };

    screenRotation = {
      enable = mkEnableOption "automatic screen rotation using IIO sensors";

      package = mkPackageOption pkgs "iio-hyprland" {};
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gtk3
    ];

    # NOTE: This gives granular control over which cards should be used, in order, when rendering Hyprland.
    environment.variables =
      {
        NIXOS_OZONE_WL = "1";
      }
      // (optionalAttrs (builtins.length cfg.renderingCards > 0) {
        AQ_DRM_DEVICES = concatStringsSep ":" (cfg.renderingCards);
      });

    qt = {
      enable = true;
      platformTheme = "gtk2";
    };

    services.dbus.packages = [pkgs.gcr];

    services.gvfs.enable = true;

    services.gnome.gnome-keyring.enable = true;

    services.gnome.gnome-settings-daemon.enable = true;

    programs.dconf.enable = true;

    security.pam.services.swaylock.text = optionalString cfg.enableSwaylockPam ''
      # PAM configuration file for the swaylock screen locker. By default, it includes
      # the 'login' configuration file (see /etc/pam.d/login)
      auth include login
    '';

    security.pam.services.hyprlock.text = optionalString cfg.enableHyprlockPam ''
      # PAM configuration file for the swaylock screen locker. By default, it includes
      # the 'login' configuration file (see /etc/pam.d/login)
      auth include login
    '';

    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      description = "Gnome Polkit Authentication Agent";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    programs = {
      hyprland = {
        enable = true;
        package = finalPackage;
        withUWSM = true;
        xwayland = {
          enable = true;
        };
      };

      iio-hyprland = {
        inherit (cfg.screenRotation) enable package;
      };
    };
  };
}
