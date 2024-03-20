{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.hellebore.sound;
  toPeriod = quantum: "${toString quantum}/${toString cfg.lowLatency.rate}";
in {
  options.hellebore.sound = {
    enable = mkEnableOption "Hellebore sound configuration";

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

  config = mkIf cfg.enable {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      wireplumber.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;

      extraConfig.pipewire."92-low-latency" = mkIf cfg.lowLatency.enable {
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
    };

    hardware = {
      # IMPORTANT: disable pulseaudio when using pipewire
      pulseaudio.enable = false;
    };
  };
}
