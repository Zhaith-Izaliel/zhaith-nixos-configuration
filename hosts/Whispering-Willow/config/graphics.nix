{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;

    layout = "fr";

    libinput.enable = true;

    windowManager.leftwm.enable = true;
  };
}

