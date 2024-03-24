{
  os-config,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types optional getExe mkPackageOption;
  cfg = config.hellebore.desktop-environment.mail;
in {
  options.hellebore.desktop-environment.mail = {
    enable = mkOption {
      default = os-config.programs.evolution.enable;
      description = "Enable Hellebore Mail client";
      type = types.bool;
    };

    package = mkPackageOption pkgs "thunderbird-bin" {};

    bin = mkOption {
      default = getExe cfg.package;
      type = types.str;
      description = "Get the package binary";
      readOnly = true;
    };

    protonmail.enable = mkEnableOption "Protonmail support";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.protonmail.enable -> os-config.services.gnome.gnome-keyring.enable;
        message = "Gnome keyring needs to be enable to allow Protonmail-Bridge
        to store passwords locally";
      }
    ];

    home.packages = optional cfg.protonmail.enable pkgs.protonmail-bridge;

    programs.thunderbird = {
      inherit (cfg) package;
      enable = true;
      profiles."zhaith".isDefault = true;
    };

    systemd.user.services.protonmail-bridge = mkIf cfg.protonmail.enable {
      Unit = {
        Description = "Protonmail Bridge";
        Wants = [
          "network.target"
          "gnome-keyring.service"
        ];
      };

      Service = {
        Type = "simple";
        Restart = "always";
        Environment = "PATH=${pkgs.gnome.gnome-keyring}/bin";
        ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --grpc --log-level info";
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
