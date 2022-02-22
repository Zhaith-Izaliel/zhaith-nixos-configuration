# Base config
{ config, pkgs, ...}:

{
  # Allow proprietary packages
  nixpkgs.config.allowUnfree = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";
}