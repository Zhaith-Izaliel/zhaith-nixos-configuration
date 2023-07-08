{ ... }:

{
  # Enable sound.
  security.rtkit.enable = true;



  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware = {
    # IMPORTANT: disable pulseaudio when using pipewire
    pulseaudio = {
      enable = false;
    };
    bluetooth.enable = true;
  };
}

