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
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-Protocol $scheme;
              proxy_set_header X-Forwarded-Host $http_host;
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

