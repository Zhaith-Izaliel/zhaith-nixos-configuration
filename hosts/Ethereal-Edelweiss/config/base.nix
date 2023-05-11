# Base config
{ config, pkgs, ...}:

{
  # Allow proprietary packages
  nixpkgs.config.allowUnfree = true;

  # Home manager
  environment.systemPackages = with pkgs; [
    home-manager
  ];

  # Set your time zone.
  time.timeZone = "Europe/Paris";
}