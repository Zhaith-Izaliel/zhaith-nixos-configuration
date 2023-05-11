{ config, pkgs, ... }:

{
  networking = {
    hostName = "Ethereal-Edelweiss"; # Define your hostname.
    domain = "ethereal-edelweiss.cloud";

    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    interfaces = {
      wlp3s0.useDHCP = true;
      enp4s0.useDHCP = true;
    };
    # Configure network proxy if necessary
    # proxy = {
      # default = "http://user:password@proxy:port/";
      # noProxy = "127.0.0.1,localhost,internal.domain";
    # };

    # Open ports in the firewall.
    firewall.allowedTCPPorts = [
      80
      25
      443
    ];

    # Or disable the firewall altogether.
    # firewall.enable = false;
  };
}
