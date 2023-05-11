{ config, pkgs, ... }:

{
  services.ddclient = {
    enable = true;
    use = "web, web=checkip.dyndns.com, web-skip='Current IP Address: '";
    username = "ethereal-edelweiss.cloud-zhaith";
    server = "www.ovh.com";
    domains = [
      "nextcloud.ethereal-edelweiss.cloud"
      "jellyfin.ethereal-edelweiss.cloud"
      # "books.ethereal-edelweiss.cloud"
    ];
    quiet = true;
    passwordFile = "/var/ddclient-password";
    protocol = "dyndns2";
    zone = "dns101.ovh.net";
  };
}