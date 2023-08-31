{ config, lib, ... }:

with lib;

let
  cfg = config.hellebore.sound;
in
{
  options.hellebore.sound = {
    enable = mkEnableOption "Hellebore sound configuration";
  };

  config = mkIf cfg.enable {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      wireplumber.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    hardware = {
      # IMPORTANT: disable pulseaudio when using pipewire
      pulseaudio.enable = false;
    };
  };
}

