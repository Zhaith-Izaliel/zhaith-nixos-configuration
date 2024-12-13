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
