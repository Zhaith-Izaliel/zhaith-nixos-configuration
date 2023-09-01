{ config, inputs, lib, pkgs, ... }:

with lib;

let
  cfg = config.hellebore.network;
  mkMergeTopLevel = (import ../../lib/default.nix { inherit inputs; }).mkMergeTopLevel;
in
{
  options.hellebore.network = {
    enable = mkEnableOption "Hellebore network configuration";

    enableNetworkManager = mkEnableOption "Hellebore NetworkManager configuration";

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

  config = mkIf cfg.enable {
    assertions = [
      {
        assertions = cfg.enable -> (builtins.length cfg.interfaces) > 0;
        message = "You have to define at least one interface.";
      }
    ];

    networking.networkmanager = mkIf cfg.enableNetworkManager {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };

    programs.nm-applet = mkIf cfg.enableNetworkManager {
      enable = true;
      indicator = false;
    };

    environment.systemPackages = lists.optional cfg.enableNetworkManager
    pkgs.openvpn;

    networking = {
      inherit (cfg) domain;

      firewall = {
        inherit (cfg) allowedTCPPorts allowedUDPPorts;
      };

      interfaces = mkMerge (builtins.map
        (item: { ${item}.useDHCP = true; })
        cfg.interfaces
      );
    };
  };
}

