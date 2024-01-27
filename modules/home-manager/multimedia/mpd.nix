{
  os-config,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  visualizer = {
    type = "fifo";
    name = "visualizer";
    path = "/tmp/mpd.fifo";
    format = "44100:16:2";
  }; # TODO: might need to move that into the config
  cfg = config.hellebore.multimedia.mpd;
in {
  options.hellebore.multimedia.mpd = {
    enable = mkEnableOption "Hellebore's MPD config";

    enableDiscordRPC = mkEnableOption "MPD integration with Discord RPC";

    musicDirectory = mkOption {
      type = types.path;
      default = /${config.home.homeDirectory}/Music;
      description = "Music directory for MPD.";
    };

    visualizer = {
      enable = mkEnableOption "NCMPCPP visualizer module";

      type = mkOption {
        type = types.enum [
          "spectrum"
          "wave"
          "wave_filled"
          "ellipse"
        ];
        default = "spectrum";
        description = "The visualizer type, either spectrum, wave, wave_filled
        or ellipse.";
      };

      look = mkOption {
        type = types.str;
        default = "·│";
        description = "The visualizer look. Used only with spectrum.";
      };

      spectrumSmoothLook = mkEnableOption "Visualizer's spectrum smooth look";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> os-config.services.pipewire.enable;
        message = "Hellebore's MPD configuration relies on pipewire to be
        enabled on your system globally.";
      }
    ];

    services = {
      mpd = {
        enable = true;
        musicDirectory = cfg.musicDirectory;
        extraConfig =
          ''
            # must specify one or more outputs in order to play audio!
            # (e.g. ALSA, PulseAudio, PipeWire), see next sections
            audio_output {
              type "pipewire"
              name "MPD-Pipewire-Output"
            }
          ''
          + strings.optionalString cfg.visualizer.enable
          ''
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
        enable = cfg.enableDiscordRPC;
      };

      mpdris2 = {
        enable = true;
        multimediaKeys = true;
        mpd.musicDirectory = cfg.musicDirectory;
      };
    };

    programs.ncmpcpp = {
      enable = true;
      package = pkgs.ncmpcpp.override {visualizerSupport = cfg.visualizer.enable;};
      settings = mkIf cfg.visualizer.enable {
        visualizer_data_source = visualizer.path;
        visualizer_output_name = visualizer.name;
        visualizer_in_stereo = "yes";
        visualizer_type = cfg.visualizer.type;
        visualizer_look = cfg.visualizer.look;
        visualizer_spectrum_smooth_look = cfg.visualizer.spectrumSmoothLook;
      };
    };
  };
}
