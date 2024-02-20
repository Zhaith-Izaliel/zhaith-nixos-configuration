{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hellebore.hyprland;
in {
  options.hellebore.hyprland = {
    enable = mkEnableOption "Hellebore Hyprland configuration";

    package = mkOption {
      type = types.package;
      default = pkgs.hyprland;
      description = "Override default Hyprland package";
    };

    enableSwaylockPam = mkEnableOption "Swaylock PAM configuration";

    enableEvolution = mkEnableOption "Evolution PIM";

    useHack = mkEnableOption "Use a patched Hyprland version to fix wayland's socket buffer size overflowing (TEMP)";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.useHack -> !config.hellebore.vm.enable;
        message = "Using the patched version of Hyprland conflicts with virt-manager.";
      }
    ];

    warnings = optional cfg.useHack "Using a patched Hyprland version is a hack in itself and should be removed after https://github.com/swaywm/sway/issues/7645 is fixed, or https://gitlab.freedesktop.org/wayland/wayland/-/merge_requests/188 is merged and deployed on Wayland.";

    environment.systemPackages = with pkgs;
      [
        gtk3
      ]
      ++ optional cfg.useHack pkgs.hyprland-patched;

    qt.enable = true;

    qt.platformTheme = "gtk2";

    qt.style = "gtk2";

    services.gvfs.enable = true;

    services.gnome.gnome-keyring.enable = true;

    services.gnome.gnome-settings-daemon.enable = true;

    programs.dconf.enable = true;

    programs.evolution.enable = cfg.enableEvolution;

    security.pam.services.swaylock.text = strings.optionalString cfg.enableSwaylockPam ''
      # PAM configuration file for the swaylock screen locker. By default, it includes
      # the 'login' configuration file (see /etc/pam.d/login)
      auth include login
    '';

    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
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

    boot.extraModprobeConfig = ''
      blacklist nouveau
      options nouveau modeset=0
    '';

    boot.kernel.sysctl = mkIf cfg.useHack {
      "net.core.wmem_max" = 16777216;
    };

    services.xserver.displayManager.session = optional cfg.useHack {
      manage = "desktop";
      name = "hyprland-patched";
      start = ''
        ${getExe pkgs.hyprland-patched} &
        waitPID=$!
      '';
    };

    programs.hyprland = {
      enable = true;
      package = cfg.package;
      xwayland = {
        enable = true;
      };
    };
  };
}
