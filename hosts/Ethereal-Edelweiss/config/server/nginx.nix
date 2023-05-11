{ config, pkgs, ...}:

{
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "jellyfin.ethereal-edelweiss.cloud" = { # Jellyfin
        addSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            proxyPass = "http://localhost:8096";
          };
          "/socket" = {
            proxyPass = "http://localhost:8096";
            extraConfig = ''
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";
              proxy_set_header X-Forwarded-Protocol $scheme;

            '';
          };
        };
      };

      "books.ethereal-edelweiss.cloud" = { # Jellyfin
        addSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:8083";
        };
      };

      "nextcloud.ethereal-edelweiss.cloud" = { # Nextcloud
        addSSL = true;
        enableACME = true;
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    certs = {
      "nextcloud.ethereal-edelweiss.cloud".email = "virgil.ribeyre@protonmail.com";
      "jellyfin.ethereal-edelweiss.cloud".email = "virgil.ribeyre@protonmail.com";
      "books.ethereal-edelweiss.cloud".email = "virgil.ribeyre@protonmail.com";
    };
  };
}