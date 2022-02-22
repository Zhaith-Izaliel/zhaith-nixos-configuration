# Enable the VPN Configuration.
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    protonvpn-gui
    protonvpn-cli
  ];
}