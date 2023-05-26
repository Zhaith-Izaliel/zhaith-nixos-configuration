{ config, pkgs, ... }:

let
  # IMPORTANT Tweak these values for pipewire low-latency setups
  quantums = 64;
  clockRate = 48000;
  # QUERY can't I directly use curly dollar instead?
  quantumsString = builtins.toString(quantums);
  clockRateString = builtins.toString(clockRate);
in
{
  # Enable sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # Low latency config
    config.pipewire = {
      "context.properties" = {
        "link.max-buffers" = 16;
        "log.level" = 2;
        "default.clock.rate" = clockRate;
        "default.clock.quantum" = quantums;
        "default.clock.min-quantum" = quantums;
        "default.clock.max-quantum" = quantums;
        "core.daemon" = true;
        "core.name" = "pipewire-0";
      };
      "context.modules" = [
        {
          name = "libpipewire-module-rtkit";
          args = {
            "nice.level" = -15;
            "rt.prio" = 88;
            "rt.time.soft" = 200000;
            "rt.time.hard" = 200000;
          };
          flags = [ "ifexists" "nofail" ];
        }
        { name = "libpipewire-module-protocol-native"; }
        { name = "libpipewire-module-profiler"; }
        { name = "libpipewire-module-metadata"; }
        { name = "libpipewire-module-spa-device-factory"; }
        { name = "libpipewire-module-spa-node-factory"; }
        { name = "libpipewire-module-client-node"; }
        { name = "libpipewire-module-client-device"; }
        {
          name = "libpipewire-module-portal";
          flags = [ "ifexists" "nofail" ];
        }
        {
          name = "libpipewire-module-access";
          args = {};
        }
        { name = "libpipewire-module-adapter"; }
        { name = "libpipewire-module-link-factory"; }
        { name = "libpipewire-module-session-manager"; }
      ];
    };

    config.pipewire-pulse = {
      "context.properties" = {
        "log.level" = 2;
      };
      "context.modules" = [
        {
          name = "libpipewire-module-rtkit";
          args = {
            "nice.level" = -15;
            "rt.prio" = 88;
            "rt.time.soft" = 200000;
            "rt.time.hard" = 200000;
          };
          flags = [ "ifexists" "nofail" ];
        }
        { name = "libpipewire-module-protocol-native"; }
        { name = "libpipewire-module-client-node"; }
        { name = "libpipewire-module-adapter"; }
        { name = "libpipewire-module-metadata"; }
        {
          name = "libpipewire-module-protocol-pulse";
          args = {
            "pulse.min.req" = "${quantumsString}/${clockRateString}";
            "pulse.default.req" = "${quantumsString}/${clockRateString}";
            "pulse.max.req" = "${quantumsString}/${clockRateString}";
            "pulse.min.quantum" = "${quantumsString}/${clockRateString}";
            "pulse.max.quantum" = "${quantumsString}/${clockRateString}";
            "server.address" = [ "unix:native" ];
          };
        }
      ];
      "stream.properties" = {
        "node.latency" = "${quantumsString}/${clockRateString}";
        "resample.quality" = 1;
      };
    };
  };
  hardware = {
      pulseaudio = {
        enable = false;
    #   package = pkgs.pulseaudioFull;
      };
    bluetooth.enable = true;
  };
}

