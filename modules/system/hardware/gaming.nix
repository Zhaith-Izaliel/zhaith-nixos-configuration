{ lib, config, pkgs, ...  }:


let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hellebore.hardware.gaming;
in
{
  options.hellebore.hardware.gaming = {
    enable = mkEnableOption "Hellebore's gaming hardware support through Piper.";
  };

  config = mkIf cfg.enable {
    services.ratbagd.enable = true; # NOTE: Needed for Piper

    environment.systemPackages = with pkgs; [
      piper
    ];
  };
}

