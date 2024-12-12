{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    mkPackageOption
    mkMerge
    optional
    optionals
    ;

  cfg = config.hellebore.sound;
  toPeriod = quantum: "${toString quantum}/${toString cfg.lowLatency.rate}";
in {
  options.hellebore.sound = {
    enable = mkEnableOption "Hellebore sound configuration";

    package = mkPackageOption pkgs "pipewire" {};

    bluetoothEnhancements = mkEnableOption "the mSBC and SBC-XQ bluetooth codec in Wireplumber.";

    lowLatency = {
      enable = mkEnableOption "PipeWire low-latency configuration";

      rate = mkOption {
        default = 48000;
        type = types.ints.unsigned;
        description = "Defines the clock rate for the audio period in PipeWire.";
      };

      quantum = mkOption {
        default = 32;
        type = types.ints.unsigned;
        description = "Defines the quantum size for the audio period in
        PipeWire.";
      };

      minQuantum = mkOption {
        default = 32;
        type = types.ints.unsigned;
        description = "Defines the minimum quantum size for the audio period
          in PipeWire.";
      };

      maxQuantum = mkOption {
        default = 32;
        type = types.ints.unsigned;
        description = "Defines the maximum quantum size for the audio period in
        PipeWire.";
      };
    };

    soundSharing = {
      enable = mkEnableOption "sound sharing between Linux computers over the network using pipewire-pulseaudio";

      mode = mkOption {
        type = types.enum ["sender" "receiver"];
        default = "";
        description = "Defines if this machine is the receiver or the sender.";
      };

      receiverAddress = mkOption {
        type = types.nonEmptyStr;
        default = "";
        description = "The receiver IP address to connect to.";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      security.rtkit.enable = true;

      services.pipewire = {
        inherit (cfg) package;
        enable = true;

        wireplumber = {
          enable = true;
        };

        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };

      hardware = {
        # IMPORTANT: disable pulseaudio when using pipewire
        pulseaudio.enable = false;
      };
    }

    (mkIf cfg.bluetoothEnhancements {
      services.pipewire.wireplumber.extraConfig.bluetoothEnhancements = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.roles" = ["hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag"];
        };
      };
    })

    (mkIf cfg.soundSharing.enable {
      services.avahi = {
        enable = true;
        openFirewall = true;

        publish = mkIf (cfg.soundSharing.mode == "receiver") {
          enable = true;
          userServices = true;
        };
      };

      services.pipewire.extraConfig."50-network-sharing" = {
        context.modules =
          (optional (cfg.soundSharing.mode == "receiver")
            {
              name = "libpipewire-module-roc-source";
              args = {
                local.ip = "0.0.0.0";
                resampler.profile = "medium";
                fec.code = "rs8m";
                sess.latency.msec = 100;
                local.source.port = 10001;
                local.repair.port = 10002;
                source.name = "Roc Source";
                source.props = {
                  node.name = "roc-source";
                };
              };
            })
          ++ (optional (cfg.soundSharing.mode == "sender") {
            name = "libpipewire-module-roc-sink";
            args = {
              fec.code = "rs8m";
              remote.ip = cfg.soundSharing.receiverAddress;
              remote.source.port = 10001;
              remote.repair.port = 10002;
              sink.name = "Roc Sink";
              sink.props = {
                node.name = "roc-sink";
              };
            };
          });
      };
    })

    (mkIf cfg.lowLatency.enable {
      services.pipewire.extraConfig.pipewire."92-low-latency" = {
        context = {
          properties = {
            default.clock.rate = cfg.lowLatency.rate;
            default.clock.quantum = cfg.lowLatency.quantum;
            default.clock.min-quantum = cfg.lowLatency.minQuantum;
            default.clock.max-quantum = cfg.lowLatency.maxQuantum;
          };
          modules = [
            {
              name = "libpipewire-module-protocol-pulse";
              args = {
                pulse.min.req = toPeriod cfg.lowLatency.minQuantum;
                pulse.default.req = toPeriod cfg.lowLatency.quantum;
                pulse.max.req = toPeriod cfg.lowLatency.maxQuantum;
                pulse.min.quantum = toPeriod cfg.lowLatency.minQuantum;
                pulse.max.quantum = toPeriod cfg.lowLatency.maxQuantum;
              };
            }
          ];
        };
        stream.properties = {
          node.latency = toPeriod cfg.lowLatency.quantum;
          resample.quality = 1;
        };
      };
    })
  ]);
}
