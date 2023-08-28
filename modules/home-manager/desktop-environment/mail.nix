{ nixosConfig, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.desktop-environment.mail;
in
{
  options.hellebore.desktop-environment.mail = {
    enable = mkEnableOption "Hellebore Mail clients";
    protonmail.enable = mkEnableOption "Protonmail support";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.protonmail.enable -> nixosConfig.services.gnome.gnome-keyring.enable;
        message = "Gnome keyring needs to be enable to allow Protonmail-Bridge
        to store passwords locally";
      }
    ];

    home.packages = with pkgs; [
      evolution
    ] ++ lists.optional cfg.protonmail.enable pkgs.protonmail-bridge;

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
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}

