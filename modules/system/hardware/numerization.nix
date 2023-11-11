{ config, lib, ... }:

with lib;

let
  cfg = config.hellebore.hardware.numerization;
in
{
  options.hellebore.hardware.numerization = {
    enable = mkEnableOption "Numerization support";
  };

  config = mkIf cfg.enable {
    hardware.sane.enable = true;
  };
}

