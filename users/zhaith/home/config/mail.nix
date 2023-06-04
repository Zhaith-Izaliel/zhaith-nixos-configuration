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
      ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --no-window --log-level info";
    };

    Install = {
      WantedBy = [ "gnome-session@gnome.target" ];
    };
  };
}

