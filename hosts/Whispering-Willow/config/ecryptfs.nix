{ config, pkgs, ... }:

{
  boot.kernelModules = [ "ecryptfs" ];
  environment.systemPackages = with pkgs; [
    ecryptfs
    ecryptfs-helper
  ];
  security.pam.enableEcryptfs = true;
}