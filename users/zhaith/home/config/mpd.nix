{config, pkgs, ...}:

{
  services = {
    mpd = {
      enable = true;
      musicDirectory = ~/Music;
      extraConfig = ''
        # must specify one or more outputs in order to play audio!
        # (e.g. ALSA, PulseAudio, PipeWire), see next sections
        audio_output {
          type "pipewire"
          name "MPD-Pipewire-Output"
        }
      '';
    };

    mpd-discord-rpc = {
      enable = true;
    };
  };

  programs.ncmpcpp = {
    enable = true;
  };
}
