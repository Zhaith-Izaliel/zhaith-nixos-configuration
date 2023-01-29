{ config, pkgs, ... }:

let
  replaySorcerySink = "replaySorcerySink";
  replaySorcerySound = "${replaySorcerySink}.monitor";
in
{
  environment.systemPackages = with pkgs; [
    vlc
    kid3
    ffmpeg
    input-remapper
  ];

  services.replay-sorcery = {
    enable = true;
    settings = {
      # The duration of the recording in seconds
      # Default value: 30
      recordSeconds = 180;

      # The key name and key modifiers (as a set of flags) to press to save a video
      # Default value: r
      keyName = "r";

      # Possible values: ctrl, shift, alt, super
      # Default value: ctrl+super
      keyMods = "ctrl+super";

      # Where to save the output file
      # Possible values: a strftime formatted file path
      # Default value: ~/Videos/ReplaySorcery_%F_%H-%M-%S.mp4
      outputFile = "~/Videos/ReplaySorcery/%F_%H-%M-%S.mp4";

      # The audio input backend to use for audio recording
      # Possible values: none, auto, pulse
      # Default value: auto
      audioInput = "pulse";

      # The name of the input audio device
      # For pulse, see `pactl list sources`
      # Possible values: auto, system, or a device string
      # Default value: auto
      audioDevice = "${replaySorcerySound}";
    };
  };
}