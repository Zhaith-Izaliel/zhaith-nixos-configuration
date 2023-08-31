{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.network;
in
{
  options.hellebore.network = {
    enable = mkEnableOption "Hellebore network configuration";

    interfaces = mkOption {
      type = types.listOf types.nonEmptyStr;
      default = [];
      description = "Network interfaces to enable.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertions = cfg.enable -> (builtins.length cfg.interfaces) > 0;
          message = "You have to define at least one interface.";
        }
      ];
    }
    {
      networking.networkmanager = {
        enable = true;
        plugins = with pkgs; [
          networkmanager-openvpn
        ];
      };

      programs.nm-applet = {
        enable = true;
        indicator = false;
      };

      environment.systemPackages = with pkgs; [
        openvpn
      ];
    }
  ] ++ (builtins.map (item: { networking.interfaces.${item}.useDHCP = true; }) cfg.interfaces));

  # networking.interfaces.enp46s0.useDHCP = true;
  # networking.interfaces.wlp47s0.useDHCP = true;
}

