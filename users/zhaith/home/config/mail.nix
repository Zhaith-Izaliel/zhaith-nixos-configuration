{ pkgs, ... }:

{

  home.packages = with pkgs; [
    protonmail-bridge
  ];

  systemd.user.services.protonmail-bridge = {
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
      WantedBy = [ "hyprland-session.target" ];
    };
  };
}

