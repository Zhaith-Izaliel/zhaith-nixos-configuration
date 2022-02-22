{ config, pkgs, ... }:

{
  services = {
    printing = {
      # Enable CUPS to print documents.
      enable = true;
      drivers = with pkgs; [ epson-escpr epson-escpr2 ];
    };

    avahi = {
      enable = true;

      # Important to resolve .local domains of printers, otherwise you get an error
      # like  "Impossible to connect to XXX.local: Name or service not known"
      nssmdns = true;
    };
  };
}