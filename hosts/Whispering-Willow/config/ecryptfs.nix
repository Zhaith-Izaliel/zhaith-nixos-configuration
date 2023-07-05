{ pkgs, ... }:

{
  boot.kernelModules = [ "ecryptfs" ];

  environment.systemPackages = with pkgs; [
    ecryptfs
    ecryptfs-helper
  ];

  security.pam.enableEcryptfs = true;

  nixpkgs.config.permittedInsecurePackages = [
    "python-2.7.18.6" # DEPRECATED: for ecryptfs-helper
  ];

}

