{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    onlyoffice-bin
    evince
    qalculate-gtk
    calibre
    pandoc
    evolution
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "python-2.7.18.6" # TODO: Need to find which package it is associated with
  ];
}

