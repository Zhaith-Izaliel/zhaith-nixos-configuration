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
    ;

  cfg = config.hellebore.sound;
  toPeriod = quantum: "${toString quantum}/${toString cfg.lowLatency.rate}";
  finalPackage = cfg.package.override {rocSupport = cfg.soundSharing.enable;};
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

      openFirewall =
        (mkEnableOption null)
        // {
          description = "Whether to open the ports in the firewall.";
        };

      targetLatency = mkOption {
        type = types.ints.unsigned;
        default = 50;
        description = "Your target sound latency. Note that higher latencies will effectively delay the sound played on receiver.";
      };

      ports = let
        mkPorts = default: name:
          mkOption {
            inherit default;
            type = types.ints.unsigned;
            description = "The ${name} port for the ROC Source.";
          };
      in {
        source = mkPorts 10001 "source";
        repair = mkPorts 10002 "repair";
        control = mkPorts 10003 "control";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      security.rtkit.enable = true;

      services.pipewire = {
        enable = true;
        package = finalPackage;

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
      networking.firewall =
        mkIf (cfg.soundSharing.mode == "receiver")
        {
          allowedTCPPorts = [
            cfg.soundSharing.ports.source
            cfg.soundSharing.ports.repair
            cfg.soundSharing.ports.control
          ];

          allowedUDPPorts = [
            cfg.soundSharing.ports.source
            cfg.soundSharing.ports.repair
            cfg.soundSharing.ports.control
          ];
        };

      services.pipewire.extraConfig.pipewire = {
        "99-roc-source" = mkIf (cfg.soundSharing.mode == "receiver") {
          "context.modules" = [
            {
              name = "libpipewire-module-roc-source";
              args = {
                "fec.code" = "ldpc";
                "local.ip" = "0.0.0.0";
                "resampler.profile" = "medium";
                "sess.latency.msec" = toString cfg.soundSharing.targetLatency;
                "local.source.port" = toString cfg.soundSharing.ports.source;
                "local.repair.port" = toString cfg.soundSharing.ports.repair;
                "local.control.port" = toString cfg.soundSharing.ports.control;
                "source.name" = "Roc Source";
                "source.props" = {
                  "node.name" = "roc-source";
                };
              };
              flags = ["nofail"];
            }
          ];
        };

        "99-roc-sink" = mkIf (cfg.soundSharing.mode == "sender") {
          "context.modules" = [
            {
              name = "libpipewire-module-roc-sink";
              args = {
                "fec.code" = "ldpc";
                "remote.ip" = cfg.soundSharing.receiverAddress;
                "remote.source.port" = toString cfg.soundSharing.ports.source;
                "remote.repair.port" = toString cfg.soundSharing.ports.repair;
                "remote.control.port" = toString cfg.soundSharing.ports.control;
                "sink.name" = "Roc Sink";
                "sink.props" = {
                  "node.name" = "roc-sink";
                };
              };
            }
          ];
        };
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
