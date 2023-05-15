{config, pkgs, ...}:

let
  musicDirectory = /${config.home.homeDirectory}/Music;
  visualizer = {
    type = "fifo";
    name = "visualizer";
    path = "/tmp/mpd.fifo";
    format = "44100:16:2";
  };
in
{
  services = {
    mpd = {
      enable = true;
      musicDirectory = musicDirectory;
      extraConfig = ''
        # must specify one or more outputs in order to play audio!
        # (e.g. ALSA, PulseAudio, PipeWire), see next sections
        audio_output {
          type "pipewire"
          name "MPD-Pipewire-Output"
        }

        # Visualizer
        audio_output {
          type "${visualizer.type}"
          name "${visualizer.name}"
          path "${visualizer.path}"
          format "${visualizer.format}"
        }
      '';
      network.startWhenNeeded = false;
    };

    mpd-discord-rpc = {
      enable = true;
    };

    mpdris2 = {
      enable = true;
      multimediaKeys = true;
      mpd.musicDirectory = musicDirectory;
    };
  };

  programs.ncmpcpp = {
    enable = true;
    package = pkgs.ncmpcpp.override { visualizerSupport = true; };
    settings = {
      visualizer_data_source = visualizer.path;
      visualizer_output_name = visualizer.name;
      visualizer_in_stereo = "yes";
      visualizer_type = "spectrum";
      visualizer_look = "·│";
      visualizer_spectrum_smooth_look = false;
    };
  };
}
