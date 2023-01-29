{ config, pkgs, ... }:

let
  inputMic = "alsa_input.usb-Auna_Mic_CM900_Auna_Mic_CM900-00.mono-fallback";
  outputDesktop = "alsa_output.pci-0000_00_1f.3.analog-stereo.monitor";
  replaySorcerySink = "replaySorcerySink";
  replaySorcerySound = "${replaySorcerySink}.monitor";
in
{
  # Enable sound.
  sound.enable = true;
  hardware = {
    pulseaudio = {
      enable = true;
      extraConfig = ''
        # load-module module-null-sink sink_name="${replaySorcerySink}"
        # load-module module-loopback source="${inputMic}" sink=${replaySorcerySink}
        # load-module module-loopback source="${outputDesktop}" sink=${replaySorcerySink}
      '';
      package = pkgs.pulseaudioFull;
    };
    bluetooth.enable = true;
  };
}