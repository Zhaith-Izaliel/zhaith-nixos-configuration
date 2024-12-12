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

      port = mkOption {
        type = types.ints.unsigned;
        default = 4713;
        description = "The port of the receiver. You need it for both sender and receiver.";
      };

      mode = mkOption {
        type = types.enum ["sender" "receiver"];
        default = "";
        description = "Defines if this machine is the receiver or the sender.";
      };

      senderAddress = mkOption {
        type = types.nonEmptyStr;
        default = "";
        description = "Defines the sender IP address used to connect to it.";
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
      networking = mkIf (cfg.soundSharing.mode == "sender") {
        firewall = {
          allowedTCPPorts = [
            cfg.soundSharing.port
          ];
        };
      };

      services.pipewire.extraConfig.pipewire-pulse."50-network-sharing" = {
        pulse.cmd =
          (optional (cfg.soundSharing.mode == "sender")
            {
              cmd = "load-modules";
              args = "module-native-protocol-tcp port=${toString cfg.soundSharing.port} listen=127.0.0.1 auth-anonymous=true";
            })
          ++ (optional (cfg.soundSharing.mode == "receiver") {
            cmd = "load-modules";
            args = "module-tunnel-sink server=tcp:${cfg.soundSharing.senderAddress}:${toString cfg.soundSharing.port}";
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
