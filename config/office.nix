{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    onlyoffice-bin
    evince
    qalculate-gtk
    calibre
    geogebra6
    apostrophe
    pandoc
    evolution
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-14.2.9" # DEPRECATED here for geogebra6
  ];
}