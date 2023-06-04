{ ... }:

{
  services.ddclient = {
    enable = true;
    use = "web, web=ip4only.me";
    ssl = true;
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

