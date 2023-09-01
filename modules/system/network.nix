{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.network;
in
{
  options.hellebore.network = {
    enable = mkEnableOption "Hellebore network configuration";

    enableNetworManager = mkEnableOption "Hellebore NetworkManager configuration";

    domain = mkOption {
      type = types.str;
      default = "";
      description = "The domain hostname.";
    };

    interfaces = mkOption {
      type = types.listOf types.nonEmptyStr;
      default = [];
      description = "Network interfaces to enable.";
    };

    allowedTCPPorts = mkOption {
      type = types.listOf types.integer;
      default = [];
      description = "Allowed TCP ports in the firewall.";
    };

    allowedUDPPorts = mkOption {
      type = types.listOf types.integer;
      default = [];
      description = "Allowed UDP ports in the firewall.";
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
    (mkIf cfg.enableNetworManager {
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
    })
    {
      networking = {
        inherit (cfg) domain;

        firewall = {
          inherit (cfg) allowedTCPPorts allowedUDPPorts;
        };
      };
    }
  ] ++ (builtins.map (item: { networking.interfaces.${item}.useDHCP = true; }) cfg.interfaces));

  # networking.interfaces.enp46s0.useDHCP = true;
  # networking.interfaces.wlp47s0.useDHCP = true;
}

