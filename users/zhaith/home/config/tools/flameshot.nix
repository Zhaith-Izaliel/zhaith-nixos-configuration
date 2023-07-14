{ pkgs, lib, ... }:

{
  services.flameshot = {
    enable = true;
    package = pkgs.flameshot.overrideAttrs (final: prev: {
      USE_WAYLAND_GRIM = true;
    });
  };

  systemd.user.services.flameshot = {
    Unit = {
      Requires = lib.mkForce [];
      After = lib.mkForce [ "graphical-session-pre.target" ];
    };
  };
}

